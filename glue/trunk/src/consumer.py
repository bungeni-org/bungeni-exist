import sys, time, getopt

"""
from com.rabbitmq.client import *
import com.rabbitmq.client.AMQP
import com.rabbitmq.client.Connection
import com.rabbitmq.client.Channel
"""

"""
import glue.LOG as LOG
"""

from com.rabbitmq.client import (
    ConnectionFactory,
    QueueingConsumer
)

import org.apache.log4j.Logger as ApacheLogger

from com.xhaus.jyson import JysonCodec as json
from java.lang import (
    String,
    Thread,
    InterruptedException
    )
from java.util.concurrent import (
        CountDownLatch
        )

from glue import (
    main_queue,
    get_parl_info,
    setup_consumer_directories,
    publish_parliament_info,
    publish_languages_info_xml,
    is_exist_running,
    types_all_config,
    post_process_action,
    rabbitmq_config
    )


__author__ = "Ashok Hariharan and Anthony Oduor"
__copyright__ = "Copyright 2011, Bungeni"
__license__ = "GNU GPL v3"
__version__ = "1.1"
__maintainer__ = "Anthony Oduor"
__created__ = "20th Jun 2012"
__status__ = "Development"

LOG = ApacheLogger.getLogger("consumer")


class Logger(object):
    def __init__(self):
        self.terminal = sys.stdout
        self.log = open("log.txt", "a")

    def write(self, message):
        self.terminal.write(message)
        self.log.write(message) 
        self.log.close()

class RabbitMQClient:

    def __init__(self, config_file):
        """
        Connections and other settings here should match those set in publisher script
        """
        self.stdout = Logger()
        self.exchangeName = "bungeni_serialization_output_queue"
        self.queueName = "bungeni_serialization_output_queue"
        self.factory = ConnectionFactory()
        # !+HARCODED host
        self.config_file = config_file
        self.config = rabbitmq_config(config_file)
        self.factory.setHost(self.config.get_hostname())
        self.factory.setUsername(self.config.get_username())
        self.factory.setPassword(self.config.get_password())
        # !+HARDCODED the following need to be fixed
        #self.factory.setVirtualHost(self.config.get_vhost())
        #self.factory.setPort(self.config.get_port())
        
        self.conn = self.factory.newConnection()
        self.channel = self.conn.createChannel()
        self.channel.exchangeDeclare(self.exchangeName,"direct",False)

    def consume_msgs(self, parliament_cache_info):
        try:
            declareOk = self.channel.queueDeclare(self.queueName, True, False, False, None)
            self.channel.queueBind(self.queueName, self.exchangeName, self.queueName)
            self.consumer = QueueingConsumer(self.channel)
            self.channel.basicConsume(self.queueName, False, self.consumer)
            count = 0
            if declareOk.messageCount <= 0:
                self.stdout.write(
                    time.asctime(time.localtime(time.time())) + " NO MESSAGES \n"
                    )
            else:
                self.stdout.write(
                    time.asctime(time.localtime(time.time())) + " " + str(declareOk.messageCount) + " MESSAGES! \n"
                    )
                while (count < declareOk.messageCount):
                    delivery = QueueingConsumer.Delivery
                    delivery = self.consumer.nextDelivery()
                    message = str(String(delivery.getBody()))
                    obj_data = json.loads(message)
                    file_to_process = str(obj_data["location"])
                    file_status = main_queue(self.config_file, file_to_process, parliament_cache_info)
                    count = count + 1
                    if file_status is None:
                        print "No Parliament Information could be gathered"
                        sys.exit(0)
                    elif file_status is True:
                        # Acknowledgements to RabbitMQ the successfully, processed files
                        self.channel.basicAck(delivery.getEnvelope().getDeliveryTag(), False)
                        # post process the file : archive / delete / noaction
                        post_process_action(self.config_file, file_to_process)
                    else:
                        # Reject file, requeue for investigation or future attempts
                        self.channel.basicReject(delivery.getEnvelope().getDeliveryTag(), True)
        finally:
            try:
                if self.channel is not None:
                    self.channel.close()
            except Exception, ex:
                    LOG.error("Error while closing channel", ex)
            try:
                if self.conn is not None:
                    self.conn.close()
            except Exception, ex:
                    LOG.error("Error while closing connection", ex)



class LangInfoPublish(Thread):
    
    def __init__(self, cd_latch, config_file):
        self.latch = cd_latch
        self.config_file = config_file
        self.publish_state = False
        
    def run(self):
        try:
            self.publish_state = publish_languages_info_xml(
                self.config_file
                )        
        except Exception, e:
            print "There was an exception getting the language info", e
        finally:
            self.latch.countDown()


class ParlInfoGather(Thread):
    """
    This thread gets the parliament information and is run before the 
    main consumer thread
    
    This is only called during the queue mode of execution
    During batch serialization this is not used.
    """
    
    def __init__(self, cd_latch, config_file):
        self.latch = cd_latch
        self.parl_info = None
        self.config_file = config_file
        
    def run(self):
        try:
            self.parl_info = get_parl_info(self.config_file)
        except Exception, e:
            print "There was an exception getting the parliament info", e
        finally:
            self.latch.countDown()


class ParlInfoPublish(Thread):
    """
    This thread publishes the parliament info to bungeni
    """
    
    def __init__(self, cd_latch, config_file, parl_info):
        self.latch = cd_latch
        self.config_file = config_file
        self.parliament_cache_info = parl_info
        self.publish_state = False
        
    def run(self):
        try:
            self.publish_state = publish_parliament_info(self.config_file, self.parliament_cache_info)
        except Exception, e:
            print "There was an exception getting the parliament info", e
        finally:
            self.latch.countDown()
    
            
class QueueRunner(Thread):
    """
    This thread processes all the documents
    """
    
    def __init__(self, cd_latch, config_file, pc_info):
        self.latch = cd_latch
        self.config_file = config_file
        self.parliament_cache_info = pc_info

    def run(self):
        rmq = None
        try:
            rmq = RabbitMQClient(self.config_file)
            rmq.consume_msgs(self.parliament_cache_info)
        except Exception, e:
            print "There was an exception processing the queue", e
        finally:
            rmq = None
            self.latch.countDown()


def language_info_publish(config_file):
    language_info_continue = True
    while language_info_continue:
        latch = CountDownLatch(1)
        p_thread = LangInfoPublish(latch, config_file)
        p_thread.start()
        try:
            latch.await()
            if p_thread.publish_state:
                language_info_continue = False
        except InterruptedException, e:
            print "Language info publication thread was interrupted", e


def parliament_info_gather(config_file):
    pc_info = None
    parl_info_continue = True
    print "Parliament Info Gather Thread : Start"
    while parl_info_continue:
        time.sleep(int(__time_int__))
        parl_latch = CountDownLatch(1)
        p_thread = ParlInfoGather(parl_latch, config_file)
        p_thread.start()
        try:
            parl_latch.await()
            pc_info = p_thread.parl_info
            if pc_info.is_cache_satisfied():
                """
                If its a bicameral legislature, the 2 chambers need to be created
                first, this thread will continue until the 2 chambers have been created
                and only then process other documents
                """
                #print "XXXX parl_info cache satisfied, exiting ", pc_info
                parl_info_continue = False
            #else:
            #   print "XXX parl_info cache not satisfied, continuing", pc_info
        except InterruptedException, e:
            print "ParlInfoRunner was interrupted !", e
        finally:
            p_thread = None
            parl_latch = None
    print "Parliament Info Gather Thread : Stop"
    return pc_info
                    

def parliament_info_publish(config_file, parliament_cache_info):
    parl_push_continue = True
    success = False
    print "Parliament Info Publish Thread : Start"
    while parl_push_continue:
        time.sleep(int(__time_int__))
        parl_latch = CountDownLatch(1)
        p_thread = ParlInfoPublish(parl_latch, config_file, parliament_cache_info)
        p_thread.start()
        try:
            parl_latch.await()
            if p_thread.publish_state:
                parl_push_continue = False
                success = True
        except InterruptedException, e:
            print "ParlInfoRunner was interrupted !", e
        finally:
            p_thread = None
            parl_latch = None
    print "Parliament Info Publish Thread : Stop"
    return success


def consume_documents(config_file, parliament_cache_info):
    print "Document consumer thread: Start"
    while True:
        time.sleep(int(__time_int__))
        cd_latch = CountDownLatch(1)
        qr_thread = QueueRunner(cd_latch, config_file, parliament_cache_info)
        qr_thread.start()
        try:
            cd_latch.await()
        except InterruptedException, e:
            print "QueueRunner thread was interrupted !", e
        finally:
            qr_thread = None
            cd_latch = None
    print "Document consumer thread: Exit"
        

def exist_running(config_file):
    print "Checking if exist is running ... "
    exist_running = False
    while exist_running == False:
        try:
            print "Attempting to connect to exist ... "
            exist_running = is_exist_running(config_file)
            print "exist connection returned ... ", exist_running
        except Exception, e:
            exist_running = False
        if not exist_running:    
            print "eXist isnt running yet ! waiting for exist to start"
            time.sleep(int(__time_int__))
    return exist_running

if (len(sys.argv) >= 2):
    # process input command line options
    options, params = getopt.getopt(sys.argv[1:], "c:i:")
    __config_file__ = options[0][1]
    __time_int__ = options[1][1]
else:
    print " config.ini file and time interval must be input parameters."
    sys.exit()

# setup directories
setup_consumer_directories(
    __config_file__
    )

# wait until exist starts
exist_running(__config_file__)
# generate the type mappings
if types_all_config(__config_file__):
    # get language info
    language_info_publish(__config_file__)
    # get chamber information
    cache_info = parliament_info_gather(__config_file__)
    # publish chamber information to exist
    if parliament_info_publish(__config_file__, cache_info):
        # publish other documents to exist
        consume_documents(__config_file__, cache_info)
else:
    print "ERROR !!!! : unable to generate type_mappings from bungeni_custom , ABORTING !"
    sys.exit()
