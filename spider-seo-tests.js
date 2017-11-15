// Import Tinytest from the tinytest Meteor package.
import { Tinytest } from "meteor/tinytest";

// Import and rename a variable exported by cspider.js.
import { name as packageName } from "meteor/cspider";

// Write your tests here!
// Here is an example.
Tinytest.add('cspider - example', function (test) {
  test.equal(packageName, "cspider");
});
