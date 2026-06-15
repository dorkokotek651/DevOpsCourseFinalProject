package simulations;

import static io.gatling.javaapi.core.CoreDsl.*;
import static io.gatling.javaapi.http.HttpDsl.*;

import io.gatling.javaapi.core.*;
import io.gatling.javaapi.http.*;
import java.time.Duration;

/**
 * Load test: a steady, realistic 20 arrivals/second held for 5 minutes.
 * Represents expected normal traffic and confirms stability over time.
 */
public class LoadSimulation extends Simulation {

  private static final String BASE_URL =
      System.getProperty("baseUrl",
          System.getenv().getOrDefault("BASE_URL",
              "http://localhost:8081/compliment-tal-fellner-reich-kadmon-kokotek"));

  HttpProtocolBuilder httpProtocol =
      http.baseUrl(BASE_URL)
          .acceptHeader("text/html,application/xhtml+xml")
          .userAgentHeader("Gatling-Load");

  ScenarioBuilder scn =
      scenario("Compliment-Roast journey")
          .exec(http("Get home").get("/").check(status().is(200)))
          .pause(1)
          .exec(http("Compliment").post("/")
              .formParam("name", "LoadTester")
              .formParam("action", "compliment")
              .check(status().is(200)))
          .pause(1)
          .exec(http("Roast").post("/")
              .formParam("name", "LoadTester")
              .formParam("action", "roast")
              .check(status().is(200)));

  {
    setUp(
        scn.injectOpen(
            constantUsersPerSec(20).during(Duration.ofMinutes(5))))
        .protocols(httpProtocol);
  }
}
