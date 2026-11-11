print("--- Initializing Application User From Environment Variables ---");

// Switch to your target application database
const appDbName = process.env.MONGO_INITDB_DATABASE;
const appDb = db.getSiblingDB(appDbName);
const appUser = process.env.APP_MONGO_USER??'demo';
const appPassword = process.env.APP_MONGO_PASS??'password';

// Create the regular application user with restricted CRUD roles
db.createUser({
  user: appUser,
  pwd: appPassword, 
  roles: [
    { role: "readWrite", db: appDbName }
  ]
});

print("--- Successfully created restricted user: " + appUser + " ---");
