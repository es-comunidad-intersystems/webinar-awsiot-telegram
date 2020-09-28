Class Telegram.API.Command.v1.spec Extends %REST.Spec [ ProcedureBlock ]
{

XData OpenAPI [ MimeType = application/json ]
{
{
  "swagger": "2.0",
  "info": {
    "description": "Telegram Notification Commands API",
    "version": "1.5.0",
    "title": "Telegram Notification Commands"
  },
  "host": "iot.iris-dataplatform.es",
  "securityDefinitions": {
    "APIKeyHeader": {
      "type": "apiKey",
      "in": "header",
      "name": "secret"
    }
  },
  "security": [
    {
      "APIKeyHeader": []
    }
  ],
  "basePath": "/Telegram/API/command",
  "tags": [
    {
      "name": "command",
      "description": "Commandos recibidos de interacción con notificaciones"
    }
  ],
  "schemes": [
    "https"
  ],
  "paths": {
    "/{BotName}": {
      "post": {
        "tags": [
          "command"
        ],
        "summary": "Procesa mensajes para enviar posteriormente información según la petición recibida en texto de mensaje",
        "description": "Guarda la información sobre la acción",
        "operationId": "getNotificationByDataEntered",
        "produces": [
          "application/json"
        ],
        "parameters": [
          {
            "in": "path",
            "name": "BotName",
            "type": "string",
            "required": true
          },
          {
            "in": "body",
            "name": "updateMsg",
            "description": "Mensaje Update con información de Mensaje de texto",
            "schema": {
              "$ref": "#/definitions/UpdateMsg"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "successful operation",
            "schema": {
              "$ref": "#/definitions/Response"
            }
          },
          "500": {
            "description": "Error processing request"
          }
        }
      }
    }
  },
  "definitions": {
    "UpdateMsg": {
      "type": "object",
      "properties": {
        "update_id": {
          "type": "number",
          "example": 234
        },
        "message": {
          "$ref": "#/definitions/Message"
        }
      }
    },
    "Message": {
      "type": "object",
      "properties": {
        "message_id": {
          "type": "number",
          "example": 110432
        },
        "date": {
          "type": "integer",
          "example": 1591698386
        },
        "text": {
          "type": "string",
          "example": "/State"
        },
        "chat": {
          "$ref": "#/definitions/Chat"
        },
        "from": {
          "$ref": "#/definitions/User"
        }
      }
    },
    "Chat": {
      "type": "object",
      "properties": {
        "last_name": {
          "type": "string",
          "example": "Test Lastname"
        },
        "id": {
          "type": "integer",
          "example": 1111111
        },
        "type": {
          "type": "string",
          "example": "private"
        },
        "first_name": {
          "type": "string",
          "example": "Test Firstname"
        },
        "username": {
          "type": "string",
          "example": "Testusername"
        }
      }
    },
    "User": {
      "type": "object",
      "properties": {
        "last_name": {
          "type": "string",
          "example": "Test Lastname"
        },
        "id": {
          "type": "integer",
          "example": 1111111
        },
        "first_name": {
          "type": "string",
          "example": "Test Firstname"
        },
        "username": {
          "type": "string",
          "example": "Testusername"
        }
      }
    },
    "Response": {
      "type": "object",
      "properties": {
        "result": {
          "type": "string",
          "example": "OK"
        },
        "id": {
          "type": "integer",
          "example": 123
        }
      }
    }
  }
}
}

}
