import dotenv from 'dotenv';

dotenv.config();

import PostModel from './models/post.js';

import connectDB from './config/db.js';

import jsonPosts from './data/sample_posts.json' with { type: 'json' };

import { MONGODB_URI } from './config/utils.js';

const upload= async()=>{
    try {
        await connectDB(MONGODB_URI);
        await PostModel.deleteMany(); //This deletes all the previous data (documents) stored in the database
        await PostModel.create(jsonPosts); //This creates products (documents) in the db
        console.log("Successfully Added all data");
        process.exit(0); //If the job has been done, we need to stop the process. We provide 0 as exit code if no error occurs

    } catch (error) {
      console.log(error); 
      process.exit(1); //If any error occurs, exit with a code of 1.
    }
}

upload();