import sys
import getopt
import time
from glue import *

from com.rabbitmq.client import *
import com.rabbitmq.client.AMQP
import com.rabbitmq.client.Connection
import com.rabbitmq.client.Channel

from com.xhaus.jyson import JysonCodec as json
import java.io.IOException
from java.lang import String

__author__ = "Ashok Hariharan and Anthony Oduor"
__copyright__ = "Copyright 2011, Bungeni"
__license__ = "GNU GPL v3"
__version__ = "0.8"
__maintainer__ = "Anthony Oduor"
__created__ = "20th Jun 2012"
__status__ = "Development"

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
            self.channel.close()
            self.conn.close()

if (len(sys.argv) >= 2):
    # process input command line options
    options, params = getopt.getopt(sys.argv[1:], "c:i:")
    __config_file__ = options[0][1]
    __time_int__ = options[1][1]
else:
    print " config.ini and time interval file must be input parameters."
    sys.exit()

while True:
    time.sleep(int(__time_int__)) # of seconds to wait till next consumption of messages is done.
    try:
        rmq = RabbitMQClient()
        rmq.consume_msgs()
    except:
        pass
