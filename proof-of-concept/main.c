#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <arpa/inet.h>
#include <netinet/in.h>

#include <sys/types.h>
#include <sys/socket.h>

#include <unistd.h>

int main(int argc, char *argv[])
{
    if (argc < 2) {
        fprintf(stderr, "Usage: webapp <port>\n");
        return EXIT_FAILURE;
    }

    int port = atoi(argv[1]);

    int server_socket = socket(AF_INET, SOCK_STREAM, 0);

    if (server_socket < 0) {
        fprintf(stderr, "Couldn't create a socket\n");
        return EXIT_FAILURE;
    }

    struct sockaddr_in server_addr;
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(port);
    inet_aton("0.0.0.0", &server_addr.sin_addr);

    if (bind(server_socket,
             (struct sockaddr*) &server_addr,
             sizeof(server_addr)) < 0) {
        fprintf(stderr, "Couldn't bind the socket\n");
        return EXIT_FAILURE;
    }

    if (listen(server_socket, 50) < 0) {
        fprintf(stderr, "Couldn't listen to the socket. It's annoying.\n");
        return EXIT_FAILURE;
    }

    int client_socket = accept(server_socket, NULL, NULL);

    if (client_socket < 0) {
        fprintf(stderr, "Couldn't accept the incoming connection. It's annoying.\n");
        return EXIT_FAILURE;
    }

    const char *html =
        "<!DOCTYPE html>\n"
        "<html>\n"
        "  <head>\n"
        "    <title>Hello, World</title>\n"
        "  </head>\n"
        "  <body>\n"
        "    <h1>Hello, World!</h1>\n"
        "    <h2>Foo Bar</h2>\n"
        "  </body>\n"
         "</html>\n";

    dprintf(client_socket,
            "HTTP/1.1 200 OK\r\n"
            "Content-Type: text/html\r\n"
            "Content-Length: %d\r\n"
            "\r\n"
            "%s",
            strlen(html), html);

    close(server_socket);
    close(client_socket);

    printf("Finished\n");

    return EXIT_SUCCESS;
}
