import sys, time, getopt

"""
from com.rabbitmq.client import *
import com.rabbitmq.client.AMQP
import com.rabbitmq.client.Connection
import com.rabbitmq.client.Channel
"""

from java.lang import InterruptedException




"""
import glue.LOG as LOG
"""
from glue import (
    main_queue
)

from com.rabbitmq.client import (
    ConnectionFactory,
    QueueingConsumer
)



import org.apache.log4j.Logger as ApacheLogger



from com.xhaus.jyson import JysonCodec as json
from java.lang import String
from java.lang import Thread
from java.util import (
        ArrayList
        )
from java.util.concurrent import (
        CountDownLatch
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

    def __init__(self):
        """
        Connections and other settings here should match those set in publisher script
        """
        self.stdout = Logger()
        self.exchangeName = "bungeni_serialization_output_queue"
        self.queueName = "bungeni_serialization_output_queue"
        self.factory = ConnectionFactory()
        self.factory.setHost("localhost")
        self.conn = self.factory.newConnection()
        self.channel = self.conn.createChannel()
        self.channel.exchangeDeclare(self.exchangeName,"direct",False)

    def consume_msgs(self):
        try:
            declareOk = self.channel.queueDeclare(self.queueName, True, False, False, None)
            self.channel.queueBind(self.queueName, self.exchangeName, self.queueName)
            self.consumer = QueueingConsumer(self.channel)
            self.channel.basicConsume(self.queueName, False, self.consumer)
            count = 0
            if declareOk.messageCount <= 0:
                self.stdout.write(time.asctime(time.localtime(time.time())) + " NO MESSAGES \n")
            else:
                self.stdout.write(time.asctime(time.localtime(time.time())) + " " + str(declareOk.messageCount) + " MESSAGES! \n")
                while (count < declareOk.messageCount):
                    delivery = QueueingConsumer.Delivery
                    delivery = self.consumer.nextDelivery()
                    message = str(String(delivery.getBody()))
                    obj_data = json.loads(message)
                    file_status = main_queue(__config_file__, str(obj_data['location']))
                    count = count + 1
                    if file_status is None:
                        print "No Parliament Information could be gathered"
                        sys.exit(0)
                    elif file_status is True:
                        # Acknowledgements to RabbitMQ the successfully, processed files
                        self.channel.basicAck(delivery.getEnvelope().getDeliveryTag(), False)
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

class QueueRunner(Thread):
    
    def __init__(self, cd_latch):
        self.latch = cd_latch

    def run(self):
        try:
            rmq = RabbitMQClient()
            rmq.consume_msgs()
        except e:
            print "There was an exception processing the queue", e
        finally:
            self.latch.countDown()

if (len(sys.argv) >= 2):
    # process input command line options
    options, params = getopt.getopt(sys.argv[1:], "c:i:")
    __config_file__ = options[0][1]
    __time_int__ = options[1][1]
else:
    print " config.ini and time interval file must be input parameters."
    sys.exit()

while True:
    time.sleep(int(__time_int__))
    cd_latch = CountDownLatch(1)
    qr_thread = QueueRunner(cd_latch)
    qr_thread.start()
    try:
        cd_latch.await()
    except InterruptedException, e:
        print "QueueRunner thread was interrupted !", e
    
