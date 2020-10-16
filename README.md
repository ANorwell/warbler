# warbler

An AWS lambda-based chat service, managed by Terraform.

Warbler is a toy project using AWS serverless primitives to build a small chat service. Processing is handled by lambda functions, DynamoDB is used for storage, and static frontend assets are hosted on S3.

All AWS resources are defined as terraform configuration files.

## Diagram
```
+-----------+        +-----------+                          +---------+       +-----------+
|           |        |           |    +-------------+       |         |       |           |
| Frontend  |        | Read/Write+---->     SNS     +-------> Writer  +------->           |
|           +------->+    API    |    +-------------+       |         |       |   Store   |
|           |        |           |                          |         |       | (DynamoDB)|
+-----------+        +-----------+                          +---------+       |           |
                                 |                                            |           |
                                 +------------------------------------------->+-----------+
                                                    Reads
```

##
