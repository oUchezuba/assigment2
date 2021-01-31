//CONSUMER
import ballerina/io;
import ballerina/kafka;
import ballerina/log;
import ballerina/lang;

kafka:ConsumerConfig consumerConfigs{
    bootstrapServers: "localhost:9092"
    groupId: "voters",
    pollingIntervalMills: 1000,
    keyDeserializerType: kafka:DES_INT,
    valueDeserializerType: kafka:DES_STRING,
    autoCommit: false

}

enum Category {
  ballot description
  profile
  voting period
  deadline
}

enum Ballot_description {
  candidates
  position
}
type candidates{
  name string
}
type Voter {
  voterid: int!
  name: string!
  address: string
  citizenship: string
  age: int
  gender: string
}
type fraud {
  voter: [Voter]
}


type Query {
  voterID(id: ID!): Voter
  name(string: ID!): Name
  address: [address]
  citizenship: [Citizenship]
  age: int
  gender: [Gender]

}

type Mutation {
  addVoters(voterID: int, name: string!, address: string!, citizenship: string, age: int, gender: [Gender]): Voter
  viewVoter(voterID: int, name: string!, address: string!, citizenship: string, age: int, gender: [Gender]): Voter
}

public function main() {
  time:Time|error deadline = time:createTime(2017, 3, 28, "Nambia");

  grpc:Headers headers = new;
  headers.addEntry("DEADLINE", deadline);

  var infoResponse = blockingEp->getVotingInfo(data, headers);

}

listener kafka:Consumer consumer = new (consumerConfigs);
service kafkaService on consumer {

     resource function viewVoters(kafka:Consumer kafkaConsumer, kafka:ConsumerRecord[] records) {
         
         foreach var kafkaRecord in records{
             processKafkaRecord(kafkaRecord);
         }

         var commitResult = kafkaConsumer->commit();
         if(commitResult is error) {
             log: printError("Error!", commitResult);
         }
     }

     resource function candidates(kafka:Consumer kafkaConsumer, kafka:ConsumerRecord[] records) {
         
         foreach var kafkaRecord in records{
             processKafkaRecord(kafkaRecord);
         }

         var commitResult = kafkaConsumer->commit();
         if(commitResult is error) {
             log: printError("Error!", commitResult);
         }
     }



 function addVoters(kafka:ConsumerRecord kafkaRecord){


     foreach var entry in records {
         byte[] message =kafkaRecord.value;
         if(message1 is string){
            byte[] serializedMsg = entry.value;
            // Convert the serialized message to string message
            string msg = encoding:byteArrayToString(serializedMsg);
            io:println("Success result");
            // log the retrieved Kafka record
            io:println(serializedMsg);
            // Update the database
            io:println("Database updated with the new voter data");
        }
        else{
         log:printErrror("Error", message1);
     }
     
 }
 }
}
 


