Answers:
Handle pages: 
1.
a) I used Paginator(and abstract counter) to handle pages loading: when reaches last five, trigger next page loading
b) Can also add a "Load More" button which I see in some apps, may better solve problem 2 regarding to rate limit. 
c) async display kit to trigger loading which reach interfaceState(Prefetch)

2. 
issues:
a) if reach limit, NYT may not able to hanlde request of punish client for not providing service for certain amount time;
b) or some users request just not response timely 
c) receiving 403 forbidden;

potential solution:
a) apply multiple keys, round robin provided from our server etc  :)
b) if our own server, use load balancing. 
c) use our server as redirect to NYT api to to control rate limit avoid api punishment from NYT side. 
d) delay request from client side by manageing rate info from response header like: X-Rate-Limit-Remaining...
e) let user know what happens and try later (if all other doesnot apply)
f) switch to "lazy loading" like "Load More" button rather to infinit scroll when received rate limit signal from server;(change design to avoid uncessary calls in general)
g) cache results 


Feature: 
1. infinite scroll
2. throttle search
3. WKWebView & delegate
4. others: search bar, footer, header;
5. viewmodel, reachbility and recover when back online

Declare: 
0. some services are reusable and I used from previous project, it is written by myself!
1. All class need prefix HTT(HotelTonght) for example;
2. Same as call category name can their functions. 
3. Can use ViewModel for Article, here not since logic relative simple;
(here I only used ArticlesViewModel, we can create ArticleViewModel for each Article instead ViewController accessing articles directly from ArticlesViewModel)
4. ViewController kind of large and can put categories in it to to other files;

TODO:
Unit Test 
on other branch 
AsyncDisplayKit;
ReactiveCocoa;


