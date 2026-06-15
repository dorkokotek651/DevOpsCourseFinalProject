package simulations;

import static io.gatling.javaapi.core.CoreDsl.*;
import static io.gatling.javaapi.http.HttpDsl.*;

import io.gatling.javaapi.core.*;
import io.gatling.javaapi.http.*;
import java.time.Duration;

/**
 * Stress test: aggressively ramp from 10 to 150 arrivals/second over 5 minutes
 * to push the app past comfortable capacity and observe how it degrades/recovers.
 */
public class StressSimulation extends Simulation {

  private static final String BASE_URL =
      System.getProperty("baseUrl",
          System.getenv().getOrDefault("BASE_URL",
              "http://localhost:8081/compliment-tal-fellner-reich-kadmon-kokotek"));

  HttpProtocolBuilder httpProtocol =
      http.baseUrl(BASE_URL)
          .acceptHeader("text/html,application/xhtml+xml")
          .userAgentHeader("Gatling-Stress");

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
            rampUsersPerSec(10).to(150).during(Duration.ofMinutes(5))))
        .protocols(httpProtocol);
  }
}
