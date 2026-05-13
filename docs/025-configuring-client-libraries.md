## LexActivator

By default, LexActivator will send license and trial activation requests to **api.cryptlex.com**

You’ll need to configure your applications to send license and trial activation requests to your On-premise installation, at the hostname:port you configured for the Cryptlex Web API server endpoint.

For example, in C/C++ applications:

```c
int status;
status = SetProductData("PASTE_CONTENT_OF_PRODUCT.DAT_FILE");
if (LA_OK != status)
{
	// handle error
}
status = SetProductId("PASTE_PRODUCT_ID", LA_USER);
if (LA_OK != status)
{
	// handle error
}
status = SetCryptlexHost("https://cryptlex-api.mycompany.com");
if (LA_OK != status)
{
	 // handle error
}
```

Similarly you can use the `SetCryptlexHost()` LexActivator API function for other programming languages.

## LexFloatServer

By default, LexFloatServer will send its own license activation request to **api.cryptlex.com**

In order to configure LexFloatServer to send the license activation requests to your On-Premise installation, you should update **cryptlexHost** property in the LexFloatServer config.yml file:

```bash
server:
  cryptlexHost: https://license-api.example.com
```
