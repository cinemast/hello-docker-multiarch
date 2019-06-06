#include <stdio.h>
#include <signal.h>
#include "httplib.h"

using namespace httplib;

Server srv;

void handler(int s) {
  srv.stop();
  printf("Stopping hello-world server\n");
  exit(0);
}

int main() {
    
  srv.Get("/hello", [](const Request& req, Response& res) {
    printf("Handling request\n");
    res.set_content("Hello World!", "text/plain");
  });

  signal(SIGINT, &handler);
  printf("Starting hello-world server\n");
  srv.listen("0.0.0.0", 1234);
  printf("Listening for requests on /hello\n");
  while(1);
  return 0;
}
