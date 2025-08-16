# Hypertext LUA
Welcome into My Project called ***HLUA***</br>
You can start by this example</br>
this is index.hlua
```lua
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <title>My 2008 HLUA Blog</title>
    <style type="text/css">
        body {
            font-family: Arial, sans-serif;
            background: #f0f0f0;
            color: #333;
            text-align: center;
            margin: 0;
            padding: 20px;
        }
        .container {
            width: 800px;
            margin: 0 auto;
            background: #fff;
            border: 1px solid #ccc;
            padding: 20px;
            -moz-border-radius: 10px;
            -webkit-border-radius: 10px;
            border-radius: 10px;
            box-shadow: 0px 5px 10px #888;
        }
        h1 {
            font-size: 2.5em;
            color: #444;
            text-shadow: 2px 2px 2px #ccc;
        }
        .post {
            border-bottom: 1px dashed #ccc;
            padding: 15px 0;
            text-align: left;
        }
        .post h2 {
            font-size: 1.5em;
            color: #0066cc;
        }
        .post p {
            line-height: 1.6;
        }
        .date {
            font-size: 0.9em;
            color: #888;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Welcome to My 2008 HLUA Blog!</h1>
        <p>This is a simple example of a dynamic page from the era of Web 2.0.</p>
        <hr />
        
        <hlua>
            -- Simulated blog posts data
            local posts = {
                {title = "First Post!", content = "Hello world! This is my first blog post using HLUA.", date = "August 16, 2008"},
                {title = "About Lua and HLUA", content = "Lua is a powerful, lightweight scripting language, perfect for embedding. HLUA is a simple way to use it for web pages.", date = "August 20, 2008"},
                {title = "CSS Gradients are cool!", content = "Loving the new CSS features with gradients and shadows. Makes sites look so much better than plain tables.", date = "August 25, 2008"}
            }

            -- Loop through the posts and print HTML
            for i, post in ipairs(posts) do
                print("<div class='post'>")
                print("<h2>" .. post.title .. "</h2>")
                print("<p class='date'>" .. post.date .. "</p>")
                print("<p>" .. post.content .. "</p>")
                print("</div>")
            end
        </hlua>

    </div>
</body>
</html>
```
# How to give a response?
You will like need this!
```lua
runtime:response(code)
```
# Example of Response Code!
```lua
runtime:response(400)
```
for return to bad request
# example.hlua?
```lua
<!DOCTYPE html>
<html>
<head>
    <title>Runtime API Example</title>
</head>
<body>
    <h1>Testing Runtime API</h1>
    <p>
        <hlua>
            -- force HTTP 400 response
            runtime:response(400)
            print("This page says: Bad request!")
        </hlua>
    </p>
    <p>
        <hlua>
            local foo = runtime:getdata("foo") or "nothing"
            print("POST/GET foo = " .. foo)
        </hlua>
    </p>
</body>
</html>

```
Here, you can use it as example!
# What is getdata?
Getdata is HLUA function that used for get args like ?foo=foo and others, and like this!
```lua
            local foo = runtime:getdata("foo") or "nothing"
            print("POST/GET foo = " .. foo)
```
