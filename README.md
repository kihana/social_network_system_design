# Social Network for Travellers

## Functional Requirements
- publish travel posts. Each post:  
  - contains photos
  - contains text
  - linked to location
- rate and comment on posts
- follow other travellers to keep track of their activity
- search for popular locations and read posts linked to those locations
- view other travellers' feeds and the user's feed based on subscriptions, in reverse chronological order

## Non‑Functional Requirements
- 10 000 000 DAU
- audience: CIS countries
- data is stored permanently
- user activity (average):
  - users publish 20 posts per year (max 5 posts per trip; average 4 trips per year), i.e. 0.05 posts per day 
  - users view 15 posts per day
  - 10% of post views result in a rating and 5% in a comment
  - 5 location search requests per user per day
  - users log in 3 times per day; therefore the user feed should be generated 3 times per day
  - users open 3 other users' feeds
  - users make 3 subscriptions per day
- limits:
  - up to 30 photos per post
  - photo size up to 3 MB
  - up to 5000 characters per post
  - no more than 50 posts per user per day
  - up to 500 comments per user per day
  - up to 1000 ratings per user per day
  - up to 500 subscriptions per user per day
  - 20 items per feed page
- seasons: summer (June–August), winter (December–January), load and traffic x 3 
- timings:
  - publish post - 3 seconds
  - rate and comment - 0.5 second
  - show search results - 2 seconds 
  - show first page of feed - 2 seconds
  - subscribe/unsubscribe - 0.5 second
- supported platforms:
  - mobile app
  - web browsers

## Load
- RPS (read) ~ 3000
  - post views (read): 10 000 000 * 15 / 86 400 = 1736
  - location search (read): 10 000 000 * 5 / 86 400 = 579
  - own feed generation (read): 10 000 000 * 3 / 86 400 = 347
  - other users' feeds (read): 10 000 000 * 3 / 86 400 = 347

- RPS (write) ~ 545
  - post publish (write): 10 000 000 * 0.05 / 86 400 = 6
  - post rating (write): 10 000 000 * (15 * 10 / 100) / 86 400 = 174
  - post comment (write): 10 000 000 * (15 * 5 / 100) / 86 400 ~ 87
  - subscription (write): 10 000 000 * 3 / 86 400 = 347

## Traffic
  - Data structure skeletons:
    - Likes:       ~ 32B
      - post_id     - 8B
      - user_id     - 8B
      - created_at  - 8B
    
    - Comment:            ~ 2KB
      - comment_id        - 8B
      - post_id           - 8B
      - user_id           - 8B
      - message           - 2000B
      - reply_id          - 8B
      - created_at        - 8B

    - Subscription:               ~ 25B
      - follower_id               - 8B
      - following_id              - 8B
      - created_at                - 8B

    - Media:            ~ 1.5KB
      - media_id        - 8B
      - post_id         - 8B
      - user_id         - 8B
      - object_key (S3) - 1KB
      - content_type    - 50B
      - size            - 8B
      - status          - 8B
      - checksum        - 32B
      - created_at      - 8B
    - Post media (S3): up to 90 MB per post (30 photos × 3 MB)
    - Thumbnail media (S3): ~ 300 KB (thumbnail)

    - Location:             ~ 2.5KB
      - location_id         - 8B
      - name                - 500B
      - address             - 500B
      - description         - 500B
      - thumbnail_url (S3)  - 1KB
      - latidude            - 8B
      - longitude           - 8B
      - post_count          - 8B
      - created_at          - 8B

    - Post (record):              ~ 7KB
      - post_id                   - 8B
      - user_id                   - 8B
      - title                     - 500B
      - body                      - 5000B
      - location_id               - 8B
      - teaser_body               - 500B
      - teaser_thumbnail (S3)     - 1KB
      - like_count                - 8B
      - comment_count             - 8B
      - created_at                - 8B
      - updated_at                - 8B
      
- RPS (read) ~ 15.3 MB/s + 28.3 MB/s + 51 MB/s + 51 MB/s ~ 145.6 MB/s
  - post load (read): 1736 * (7KB + 1.5KB) = 14756 KB/s = 14.5 MB/s
  - search location (read): 579 * 2.5KB * 20 (count) = 28950 KB/s = 28.3 MB/s
  - own feed (read): 347 * 20 (count) * 7KB = 48580 KB/s = 47.5 MB/s
  - user feed (read): same as above = 51 MB/s
  
- RPS (media read) ~ 152.6 GB/s + 3.4 GB/s + 1.9 GB/s + 1.9 GB/s ~ 159.8 GB/s
  - post media reads: 1736 * 90MB = 156240 MB/s = 152.6 GB/s
  - search location media: 579 * 300KB * 20 (count) = 3474000 KB/s = 3.4 GB/s
  - own feed media: 347 * 300KB * 20 (count) = 2082000 KB/s = 1.9 GB/s
  - user feed media: 1.9 GB/s
  
- RPS (write) ~ 54 KB/s + 5.4 KB/s + 174 KB/s + 8.5 KB/s ~ 242 KB/s
  - post publish (write): 6 * (7KB + 1.5KB) = 51 KB/s
  - post rating (write): 174 * 32B = 5568 B/s = 5.4 KB/s
  - post comment (write): 87 * 2KB = 174 KB/s
  - subscription (write): 347 * 25B = 8675 B/s = 8.5 KB/s

- RPS (media write) ~ 540 MB/s
  - post publish media (upload): 6 * 90MB = 540 MB/s

## Capacity
242 KB/s * 365 * 86400 ~ 7.5 TB per year
540 MB/s * 365 * 86400 ~ 16 PB per year (media)

### HDD
IOPS = 3000 + 545 = 3545 => 3545 / 100 ~ 36
Throughput = (145.6 MB/s + 242 KB/s) / 100 MB/s ~ 2
7.5 TB => 1 * 20 TB ~ 1

36 disks * 500 GB = 18 TB

### SSD
IOPS = 3000 + 545 = 3545 => 3545 / 1000 ~ 4
Throughput = (145.6 MB/s + 242 KB/s) / 500 MB/s ~ 1
7.5 TB => 1 * 20 TB ~ 1

4 disks * 4 TB = 16 TB

### S3
Throughput (media) = (159.8 GB/s + 540 MB/s) / ? ~ ?

