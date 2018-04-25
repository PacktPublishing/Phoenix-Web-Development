// Import Phoenix's Socket Library
import { Socket, Presence } from "phoenix";

import $ from "jquery";

// Utility functions
const pushMessage = (channel, author, message) => {
  resetTimer(channel, author);
  channel
    .push("new_message", { author, message })
    .receive("ok", res => console.log("Message sent!"))
    .receive("error", res => console.log("Failed to send message:", res));
};

// When we join the channel, do this
const onJoin = (res, channel) => {
  $(".chat-send").on("click", event => {
    event.preventDefault();
    const message = $(".chat-input").val();
    const author = $(".author-input").val();
    pushMessage(channel, author, message);
    $(".chat-input").val("");
  });
  console.log("Joined channel:", res);
};

// Add a message to the list of chat messages
const addMessage = (author, message) => {
  const chatLog = $(".chat-messages").append(
    `<li>
      <span class="author">&lt;${author}&gt;</span>
      <span class="message">${message}</span>
    </li>
    `
  );
};

// Presence Functions

// Presence default state
let presences = {};

// The timer we'll use to check the user's idle status
let idleTimeout = null;

// How long we'll wait for the user to be marked as idle
const TIMEOUT = 30 * 1000; // 30 seconds

// Provide a way to hide the current chat UI
const hideChatUI = () => {
  $("div.chat-ui").addClass("hidden");
};

// And a way to show the chat UI
const showChatUI = () => {
  $("div.chat-ui").removeClass("hidden");
};

// Load the chat, display the UI, connect to the socket
const loadChat = socket => {
  $(".join-chat").on("click", () => {
    const username = $(".author-input").val();
    if (username.length <= 0) {
      return;
    }
    showChatUI();
    connect(socket, username);
  });
};

// Given a metas array for a user, return their current status
const getStatus = metas => metas.length > 0 && metas[0]["status"];

// Sync up the list of users to the current Presence State
const syncUserList = presences => {
  $(".username-list").empty();
  Presence.list(presences, (username, { metas }) => {
    const status = getStatus(metas);
    $(".username-list").append(`<li class="${status}">${username}</li>`);
  });
};

// Reset the timer when an interaction occurs
const resetTimer = (channel, username, skipPush = false) => {
  if (!skipPush) {
    channel.push("user_active", { username });
  }
  clearTimeout(idleTimeout);
  idleTimeout = setTimeout(() => {
    channel.push("user_idle", { username });
  }, TIMEOUT);
};

// Add a new status message to the chat display
const addStatusMessage = (username, status) => {
  $(".chat-messages").append(
    `<li class="status">${username} is ${status}...</li>`
  );
};

// When Phoenix reports a change in Presence status, determine the differences
// and report the changes to the user
const handlePresenceDiff = diff => {
  // Separate out the response from the server into joins and leaves
  const { joins, leaves } = diff;
  if (!joins && !leaves) {
    // Throw out the diff if we're missing both joins and leaves!
    return;
  }
  // Next, based on the diff, get the new state of the presences variable
  presences = Presence.syncDiff(presences, diff);
  // Sync up the user list to the new state
  syncUserList(presences);
  // For all new statuses, add status messages to the chat log.
  Object.keys(joins).forEach(username => {
    const metas = joins[username]["metas"];
    const status = getStatus(metas);
    addStatusMessage(username, status);
  });
  // Finally, display messages for each person that leaves the chat too!
  Object.keys(leaves).forEach(username => {
    if (Object.keys(joins).indexOf(username) !== -1) {
      return;
    }
    addStatusMessage(username, "gone");
  });
};

// When Phoenix reports the initial state of Presence status, sync up the list of users
const handlePresenceState = state => {
  presences = Presence.syncState(presences, state);
  syncUserList(presences);
};

// Next, create a new Phoenix Socket to reuse
const socket = new Socket("/socket");

// Connect to the socket itself
socket.connect();
const connect = (socket, username) => {
  // Only connect to the socket if the polls channel actually exists!
  const enableLiveChat = document.getElementById("enable-chat-channel");
  if (!enableLiveChat) {
    return;
  }
  const chatroom = document
    .getElementById("enable-chat-channel")
    .getAttribute("data-chatroom");
  // Create a channel to handle joining/sending/receiving
  const channel = socket.channel("chat:" + chatroom, { username });

  // Next, join the topic on the channel!
  channel
    .join()
    .receive("ok", res => onJoin(res, channel))
    .receive("error", res => console.log("Failed to join channel:", res));

  channel.on("new_message", ({ author, message }) => {
    addMessage(author, message);
  });

  channel.on("presence_state", handlePresenceState);
  channel.on("presence_diff", handlePresenceDiff);

  resetTimer(channel, username, true);
};

// Finally, export the socket to be imported in app.js
export default { loadChat };
