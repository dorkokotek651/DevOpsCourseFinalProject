package simulations;

import static io.gatling.javaapi.core.CoreDsl.*;
import static io.gatling.javaapi.http.HttpDsl.*;

import io.gatling.javaapi.core.*;
import io.gatling.javaapi.http.*;
import java.time.Duration;

/**
 * Find the application's max limit: ramp open arrivals from 1 to 200 req/s over
 * 2 minutes. The point where response time / error rate climbs sharply is the
 * max limit. The assertion documents the SLO we consider "still healthy".
 */
public class MaxLimitSimulation extends Simulation {

  private static final String BASE_URL =
      System.getProperty("baseUrl",
          System.getenv().getOrDefault("BASE_URL",
              "http://localhost:8081/compliment-tal-fellner-reich-kadmon-kokotek"));

  HttpProtocolBuilder httpProtocol =
      http.baseUrl(BASE_URL)
          .acceptHeader("text/html,application/xhtml+xml")
          .userAgentHeader("Gatling-MaxLimit");

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
            rampUsersPerSec(1).to(200).during(Duration.ofMinutes(2))))
        .protocols(httpProtocol)
        .assertions(global().responseTime().percentile3().lt(2000));
  }
}
