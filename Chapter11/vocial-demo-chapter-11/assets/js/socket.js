// Import Phoenix's Socket Library
import { Socket } from "phoenix";

// Next, create a new Phoenix Socket to reuse
const socket = new Socket("/socket");

// Connect to the socket itself
socket.connect();

// Finally, export the socket to be imported in app.js
export default socket;
