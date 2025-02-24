/**
 * Cloud Function that returns a random Chuck Norris joke
 * 
 * @param {Object} req Cloud Function request context
 * @param {Object} res Cloud Function response context
 */
exports.getRandomJoke = (req, res) => {
  // CORS headers
  res.set('Access-Control-Allow-Origin', '*');
  
  if (req.method === 'OPTIONS') {
    // Handle preflight requests
    res.set('Access-Control-Allow-Methods', 'GET');
    res.set('Access-Control-Allow-Headers', 'Content-Type');
    res.set('Access-Control-Max-Age', '3600');
    res.status(204).send('');
    return;
  }
  
  // Array of Chuck Norris jokes
  const jokes = [
    "Chuck Norris doesn't read books. He stares them down until he gets the information he wants.",
    "Time waits for no man. Unless that man is Chuck Norris.",
    "If you spell Chuck Norris in Scrabble, you win. Forever.",
    "Chuck Norris can divide by zero.",
    "When Chuck Norris does a pushup, he isn't lifting himself up, he's pushing the Earth down.",
    "Chuck Norris is the reason why Waldo is hiding.",
    "Chuck Norris counted to infinity... twice.",
    "Chuck Norris doesn't wear a watch. HE decides what time it is.",
    "Chuck Norris can slam a revolving door.",
    "Chuck Norris doesn't call the wrong number. You answer the wrong phone.",
    "Chuck Norris can delete the Recycling Bin.",
    "Chuck Norris can win a game of Connect Four in only three moves.",
    "When the Boogeyman goes to sleep every night, he checks his closet for Chuck Norris.",
    "Chuck Norris once kicked a horse in the chin. Its descendants are now called giraffes."
  ];
  
  // Get a random joke
  const randomJoke = jokes[Math.floor(Math.random() * jokes.length)];
  
  // Send the joke
  res.status(200).json({
    joke: randomJoke
  });
};
