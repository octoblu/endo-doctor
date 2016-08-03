module.exports = (message, description) =>
  error = new Error message
  error.description = description
  return error
