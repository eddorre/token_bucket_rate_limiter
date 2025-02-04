A simulation of how a token based rate limiter works.

Although the class does take an identifier, it's not used currently.
Tokens are tracked only in memory. In a production setting these would likely be persisted to a key / value store like Redis.

```ruby

ruby token_bucket_rate_limiter.rb

```
Example run:

![token_bucket_rate_limiter](https://github.com/user-attachments/assets/2ad383cd-8a83-476d-9a71-c4c1208610f6)

