---
title: Onetouch Integration

language_tabs:
   - javascript
    
toc_footers:
  - <a href='https://onetouch.io/'>Documentation Powered by Onetouch.io</a>

search: true
---

# Introduction

> Displaying onetouch game on your site

```html
<html>
   <header>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.1.1/jquery.js"></script>
   </header>
   <body >
    <script type=javascript>
    
      $(document).ready(setGameURL());
       
      function setGameURL(){
        var onetouchBaseUrl = "https://prod.onetouch.io";
        var gameID = 2344234;
        var token = "3453450340fdslgkwerweropq234234serwe2342";
        var lobbyUrl = "http://your_lobby_address";
        var language = "en";
     
        var gameUrl = `${onetouchBaseUrl}/${gameID}/${token}?lobbyUrl=${encodeURIComponent(site.settings.url)}&lang=language`;
                
        $("#gameBox).attr("src",gameUrl); 
        
        return true;
      }
      
    </script>
    
    <iframe id="gameBox" src="" >
    </iframe>
    
   </body>
  </html>
```

Welcome to onetouch integration doc, landing onetouch's games on your site is as easy as creating an Iframe and pointing the source of the iframe to onetouch's url and specifying the various preferences intended for your game client.

In order to ensure that all game transaction (monetary or value wise) as a partner you need to develop a wallet API server with which we can plug into when game is initialized as well as during the game play.

# Partner Wallet Server
Partner is expected to provide a service URL for wallet operations, the service url is expected to provide the following capabilities

+ Authenticate player
+ Get Balance
+ Transact
  + Debit
  + Credit
  + Rollback 
+ Change Language

## Request Overview

The following are true for all requests made to the partner service.

+ Request is in standard JSON format
+ Requests uses the standard HTTP POST method.
+ Request are signed based on the payload contained in the request, which the partner is expected to verify  with the secure key provided. 
+ Every request to the partner wallet service is expected return the following response structure.

  
Every request contains the following fields

### Standard Request Parameters

Field   | Type    | Required | Derscription  
------  |-------- |----------| ------------  
partner |  string | Yes      | Partner name as it exist on our platform 
token   |  string | Yes      | The token for the request  

Every request must return either a successful response or an error response according to the structure described below :

### Standard success response

> Sample success response

```json
  {
    "success" : {
      "user": "432100",
      "balance": 100
    }
  }
```

Field   | Type    | Required | Derscription  
------  |-------- |----------| ------------  
success |  JSON Object | Yes      | Successful response envelope 
success.user |  string | Yes      | Player ID 
success.balance |  number | Yes      | Player Balance 


### Standard error response

> Sample error response

```json
  {
    "error" : {
      "code" : 7,
      "message" : "User has insufficient fund"
    }
  }
```

Field   | Type    | Required | Derscription  
------  |-------- |----------| ------------  
error |  JSON Object | Yes      | Failed request response envelope 
error.code |  enum | Yes      | An error code
error.message |  number | Yes      | Description of the error 


### Standard errors

> Error codes enumeration

``` python	 
	 1 = General / other error
	 2 = Invalid partner name provided
	 3 = Invalid token provided
	 4 = Invalid game provided
	 5 = Invalid user provided
	 6 = Invalid currency provided
	 7 = Insufficient user funds
	 8 = User is disabled
	 9 = Invalid message signature
	10 = User login token has been expired
```

A partner service can respond with one of the following errors :

## Authentication
> Player request authentication

```javascript
const crypto = require('crypto');
 
 /**
  * @params Array request parameters
  * @headers Array reuest headers
  **/ 
 function verifySignature(params, headers) {
   var verify = crypto.createVerify('RSA-SHA256');
   var keys = Object.keys(params).sort();
   var message = keys.map(function (key) {
       return key + "=" + params[key]; // concatenate key value pairs into a string, e.g key=value
   }).join('&'); // concatenate key value pairs into a single string delimited by '&'
   verify.update(message, 'utf8'); 
 
   // assuming the public key is stored as ONETOUCH_PUBLIC_KEY env var
   return verify.verify(process.env.ONETOUCH_PUBLIC_KEY, headers['x-onetouch-signature'], 'base64'); //Comparing your pulic key to the pre-signed value in the header.
}
```

In order to ascertain the security of incoming request, the partner service is expected to verify the genuinity and authenticity of every request by verifying the value of the request header `X-Onetouch-Signature`

This header is passed along with every request. 

Similar implementation in ```php``` can be found here http://php.net/manual/en/function.openssl-verify.php

Partner service should decline a request and response with the appropriate error message in such scenario where the key verification failed.

This endpoint retrieves all kittens.

### HTTP Request

This endpoint should validate the player

`POST http://partner_endpoint_url/auth`

### Query Parameters

Field   | Type    | Required | Derscription  
------  |-------- |----------| ------------  
Partner |  string | Yes      |  
token   |  string | Yes      | 
game    |  string | Yes      | The current game identifier in the player's client|
gameMode | string | Yes      | Game context Demo or Real money


## Get Balance

This endpoint should return the balance of a specified player

### HTTP Request

`POST http://partner_endpoint_url/getBalance`

### Query Parameters

Field      | Type          |Required       | Description |
-----------|---------------|---------------|--------------
Partner    | String        | Yes           |  |
token      | String        | Yes           |  |
game       | String        | Yes           | The current game in the player's client|
gameMode   | String        | Yes           | Game context Demo or Real money|
user       | String        | Yes           | Player ID|


## Transact

This endpoint should handle transaction operations such as `credit`, `debit`, `rollback`

### HTTP Request

`POST http://partner_endpoint_url/transact`

### Query Parameters

Field       | Type          |Required    | Description |
-----------|---------------|---------------|--------------
Partner     | string        | Yes           |  |
token       | string        | Yes           |  |
game        | string        | Yes           | The current game in the player's client|
gameMode    | string        | Yes           | Game context Demo or Real money|
user        | string        | Yes           | Player|
transaction  | string        | Yes           | Transaction ID|
round       | string        | Yes           | Round identifier|
bet         | string        | Yes           | |
type        | number        | Yes           | `0 - BET`, `1 - WIN`, `2 - ROLLBACK`|
amount      | number        | Yes           | Transaction amount|
currency    | string        | Yes           | Transaction amount currency|
reference   | string        | Yes           | Transaction reference|


## Change Language

This endpoint is for reporting the language preference changes that the user sets in the game client. 

This preference can be used next time when the game is launched, by parsing as a parameter to the client url for get game

### HTTP Request

`POST http://partner_endpoint_url/changeLanguage`

### Query Parameters

| Field       | Type          |Required    | Description |
--------------|---------------|---------------|--------------
| Partner     | string        | Yes           |  |
| token       | string        | Yes           |  |
| user        | string        | Yes           | Player|
| language    | string        | Yes           | Language identifier|