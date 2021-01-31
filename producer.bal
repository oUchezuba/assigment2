//PRODUCER
import ballerina/log;
import ballerina/http;
import ballerina/kafka;
import wso2/gateway;
import ballerina/docker; 

kafka:ProducerConfig producerConfigs = {
    bootstrapServers: "localhost:9092, localhost:9092", //producer localhost,
    clientId: "voters",
    acks: "all",
    retryCount: 3
};

kafka:Producer kafkaProducer = new (producerConfigs);

public type APIGatewayListener object {
   public {
       EndpointConfiguration config;
       http:Listener httpListener;
   }

   new () {
       httpListener = new;
   }

   public function init(EndpointConfiguration config);

   public function initEndpoint() returns (error);

   public function register(typedesc serviceType);

   public function start();

   public function deadline() returns (http:Connection);

   public function getFrauds();
};


type Voter record {
    string name;
    address address;
    string citizenship;
    string gender;
    int age;
    int voterId;
};

// Create SQL client for MySQL database
jdbc:Client voterDB = new ({
    url: config:getAsString("DATABASE_URL", "jdbc:mysql://localhost:9090/VOTER_DATA"),
    username: config:getAsString("DATABASE_USERNAME", "root"),
    password: config:getAsString("DATABASE_PASSWORD", "root"),
    poolOptions: { maximumPoolSize: 5 },
    dbOptions: { useSSL: false }
});

@docker:Config{
    name: "testVoTo"
    tag: "V4.3"
}
@docker:Expose{}

@kubernetes:Ingress {
   hostname: "",
   name: "",
   path: "/"
}

@kubernetes:Service {
   serviceType: "NodePort",
   name: ""
}

@kubernetes:Deployment {
   image: "",
   baseImage: "",
   name: "",
   copyFiles: [{ target: "",
               source: <path_to_JDBC_jar> }]
}

@http:ServiceConfig{
    basePath: "/addNew"
}


service candidates on httpListener {
    @http:ResourceConfig{
        path: "/candidates/{name}"
    }

    resource function candidates(http:Caller outboundEP, http:Request request){
        http:Response res = new;

        var payloadJson = request.getJsonPayload();

        if (payloadJson is json) {
            Candidate|error candidateData = Candidate.constructFrom(payloadJson);

            if (candidateData is candidate) {
                // Validate JSON payload
                if (candidateData.name == "") {
                        response.statusCode = 500;
                        response.setPayload("Error: JSON payload should contain " +
                        "{name:<string>");
                } else {
                    // Invoke addVoters function to save data in the MySQL database
                    json ret = viewData(candidateData.name);
                    response.setPayload("candidates": [
      {
        "name: George Paul",
        "name: Sikeba Johnson",
        "name: Sophie Maharero",
        "name: Ross De Almeida",
        "category": CANDIDATE
      },
      
);
                    
                    response.setPayload(ret);
                }
            }
        }

    }

}


service addNew on httpListener {
    @http:ResourceConfig{
        path: "/voters/{name}"
    }

resource function addVoters(http:Caller outboundEP, http:Request request){
        http:Response res = new;

        var payloadJson = request.getJsonPayload();

        if (payloadJson is json) {
            Voter|error voterData = Voter.constructFrom(payloadJson);

            if (voterData is Voter) {
                // Validate JSON payload
                if (voterData.name == "" || voterData.address == "" || voterData.citizenship == ""|| voterData.gender == ""|| voterData.age ==0 || voterData.voterId == 0 ||) {
                        response.statusCode = 400;
                        response.setPayload("Error: JSON payload should contain " +
                        "{name:<string>, address:<address>, citizenship:<string>, gender:<string>, age:<int>, voterId:<int>");
                } else {
                    // Invoke addVoters function to save data in the MySQL database
                    json ret = insertData(voterData.name, voterData.address, voterData.citizenship, voterData.gender, voterData.age, voterData.voterId);
                    response.setPayload("data": {
    "allVoters": [
      {
        "id: 1",
        "name": "Vihemba Paulus",
        "address": "Windhoek, Kleine Kuppe",
        "citinzenship: Namibian",
        "age: 43",
        "gender: male"
        "category": VOTER
      }
      {
        "id: 2",
        "name": "Kaitlyn Tarver",
        "address": "Swakopmund, Ocean View",
        "citinzenship: Namibian",
        "age: 36",
        "gender: female"
        "category": VOTER
      }
      {
        "id: 3",
        "name": "Olzen Buyanha",
        "address": "Windhoek, Kleine Kuppe",
        "citinzenship: Namibian",
        "age: 34",
        "gender: other"
        "category": VOTER
      }
    ]
    };
);
                    
                    response.setPayload(ret);
                }
            } else {
                // Send an error response in case of a conversion failure
                response.statusCode = 400;
                response.setPayload("Error: Please send the JSON payload in the correct format");
            }
        } else {
            // Send an error response in case of an error in retriving the request payload
            response.statusCode = 400;
            response.setPayload("Error: An internal error occurred");
        }

    }

}
service viewVoter on httpListener {
    @http:ResourceConfig{
        methods: ["GET"],
        path: "/voters/{voterId}"
    }

    resource function viewVoters(http:Caller outboundEP, http:Request request, voterData){
        http:Response res = new;


var voterID = ints:fromString(voterId);
        if (voterID is int) {
            // Invoke retrieveById function to retrieve data from MYSQL database
            var result = rch.readJson(voterId);

            json viewCurrentInfo = {"id":" ",
        "name": " ",
        "address": " ",
        "citinzenship":" ",
        "age":" ",
        "gender":" ",
        "category": VOTER};

            byte[] message = viewCurrentInfo.toString().toBytes();
        //
            var sendResult = kafkaProducer->send(message);
            // Send the response back to the client with the voter data
            response.setPayload(voterData);
        } 
        else if(sendResult is error){
            response.statusCode = 500;
            response.setJsonPayload("The ID entered is not registered in the system!");
            var responseResult = outboundEP->respond(response);
        }
        //Send a success
        response.setJsonPayload({"Succesfull!"});
        var responseResult = outboundEP->respond(response);
    }
    
}


service fraudVoter on httpListener {
    @http:ResourceConfig{
        methods: ["GET"],
        path: "/voters/{rejects}"
    }

    
    type ProcessedReview record {
    boolean isFraud?;
    Review review?;
    !...;
};

// Listen to port 9092 for records
listener http:Listener reviewsEP = new(9092);

@http:ServiceConfig { basePath: "/frauds" }
service getFrauds on fraudsEP {

    @http:ResourceConfig { methods: ["PUT"], path: "/submitFrauds" }
    resource function receiveFraud(http:Caller caller, http:Request req) {
        string topic = "processed-frauds";
        json message;
        json successResponse = { success: "true", message: "Voter has no fraudulent records" };
        json failureResponse = { success: "false", message: "Voter has voted more than once! Fraudulent activity recorded" };
        http:Response res = new;

        var requestPayload = req.getJsonPayload();
        if (requestPayload is error) {
            res.setJsonPayload(failureResponse);
            _ = caller->respond(res);
        } else {
            message = requestPayload;

            string header = message.header.toString();
            res.setJsonPayload(successResponse);
            _ = caller->respond(res);
            if (header == "frauds") {
                var review = Frauds.convert(message.body);
                if (review is Frauds) {
                    ProcessedFrauds processedReview = {};
                    processedFrauds.frauds = fraud;

                    }
                }
            }
        }
    }
}


service getdateInfo on httpListener {
    @http:ResourceConfig{
        methods: ["GET"],
    }
resource function getdateInfo(grpc:Caller caller, grpc:Headers headers) {
    boolean deadlineExceeded = caller->isDeadlineExceeded(headers);
}

     if(deadline = json){
        json resultMessage;
        http:Request votingManagerReq = new;
        json resultjson = check json.convert(result);

        http:Response resultResponse=  check resultMgtEP->post("Deadline reached!", resultManagerReq);
        json resultResponseJSON = check resultResponse.getJsonPayload();
    }
}
