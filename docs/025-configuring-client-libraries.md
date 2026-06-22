# Configuring Client Libraries

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

**Note:** The only additional configuration required for On Premise deployments is setting the Cryptlex host using `SetCryptlexHost()` to point to your On Premise Web API endpoint. Apart from this change, the integration and usage of LexActivator remains the same as described in our ["Using LexActivator"](https://cryptlex.com/docs/node-locked-licenses/using-lexactivator) guide.


## LexFloatServer

By default, LexFloatServer will send its own license activation request to **api.cryptlex.com**

In order to configure LexFloatServer to send the license activation requests to your On-Premise installation, you should update **cryptlexHost** property in the LexFloatServer config.yml file:

```bash
server:
  cryptlexHost: https://license-api.example.com
```
