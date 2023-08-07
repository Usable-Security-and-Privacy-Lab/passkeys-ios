# Database Structure

# Users Endpoints
## Current user info 🔐
`GET /me`
Params:
- Session cookie
Response Body:
```
{
	"user": {
		"username": String,
		"first_name": String,
		"last_name": String,
		"display_name": String,
		"is_friend": Bool,
		"friends_count": Int,
		"id": Int,
	}
}
```
## User info
`GET /users/:user_id`
Params:
- none
Response body:
```
{
	"user": {
		"username": String,
		"first_name": String,
		"last_name": String,
		"display_name": String,
		"is_friend": Bool,
		"friends_count": Int,
		"id": Int
	}
}
```
## User's friends
`GET /users/:user_id/friends`
Params:
- none
Response body:
```
{
	"friends": [
		{
			"username": String,
			"first_name": String,
			"last_name": String,
			"display_name": String,
			"id": Int
		},
		{...},
		...
	]
}
```
# Payment/Transaction Endpoints
## Make payment/charge 🔐
`POST /payments`
Params:
- Session cookie
- Action
- payee/requestee user_id 
- Note
- Amount
- Audience
Response body:
```
{
	"balance": Double,
	"payment": {
		"id": Int,
		"status": String, // (pending, settled, cancelled, denied)
		"note": String,
		"amount": Double,
		"action": String, // (pay, request)
		"date_created": Int,
		"date_completed": Int,
		"audience": String, // (public, friends, private)
		"target_username": String,
	}
}
```
## List recent payments 🔐
`GET /payments`
Params:
- Session cookie
- Action (optional)
- Actor (optional)
- Status (optional)
- Limit (optional)
- After (optional)
- Before (optional)
Response body:
```
{
	"pagination": {
		"next": String // URL of next query
	},
	"payments": [
		{...},
		...
	]
}
```
## Payment Information 🔐
`GET /payments/:payment_id`
Params:
- Session cookie
Response body:
```
{
	"payment": {...}
}
```
## Complete payment request 🔐
`PUT /payments/:payment_id`
Params:
- Session cookie
- Action (approve, deny, cancel if sender)
Response body:
```
{
	"payment: {...}
}
```
