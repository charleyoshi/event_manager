What were done:

- manipulate file input and output
- read from CSV
- transform it into a standardized format and manipulate strings
    - clean zipcode
    - clean phone number
    - use [Date](https://docs.ruby-lang.org/en/3.2/Date.html) and [Time](https://docs.ruby-lang.org/en/3.2/Time.html) class
        - find out peak registration hours
        - find out most registered weekdays
- utilize the data to contact a remote service
- populate a template with user data
- access [Google’s Civic Information API](https://developers.google.com/civic-information/) through the [Google API Client Gem](https://github.com/googleapis/google-api-ruby-client)
    - get legislators by zipcode
- use [ERB](https://docs.ruby-lang.org/en/3.2/ERB.html) (Embedded Ruby) for templating
