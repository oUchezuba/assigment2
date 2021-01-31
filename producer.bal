//PRODUCER
import ballerina/log;
import ballerina/http;
import ballerina/kafka;
import wso2/gateway;

kafka:ProducerConfig producerConfigs ={
    bootstrapServers: "localhost:9092, localhost:9092" //producer localhost,
    clientId: "voters",
    acks: "all",
    retryCount: 3
}

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
