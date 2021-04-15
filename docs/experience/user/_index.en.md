---
title: Experience As An End User
weight: 40
---

Copy the URL you just generate to the browser and you will see the following page:

![End-User-GUI](/images/end-user-gui.png)

You can input your name in the input field:

![Name-Input-Field](/images/name-input-field.png)

And click login icon.:

![Login-Icon](/images/login-icon.png)

Next time, you can input the same name to get recommendations based on the relating history. Optionally, you can just click the shortcut key to login the system. This will consider you as the new user each time:

![Look-Around](/images/look-around.png)

Suppose you login the system as the **gcr-recsys-user**. You will see the following page:

![Cold-Start](/images/cold-start.png)

You can tell that you are considered as the brand new user for this system at the right corner:

![Login-Time](/images/login-time.png)

Then you can see that the reading history and user portrait are empty:

![Empty-History-Portrait](/images/empty-history-portrait.png)

Since you are the new user, you get the recommendation list generated from the **cold start logic**. In the cold start logic, different types of news are randomly sampled:

![Cold-Start-News](/images/cold-start-news.png)

Actually, you can navigate different types of news and pick up what you like. The reading history and user portrait will change accordingly:

![Different-Types-News](/images/different-types-news.png)

After clicking at three pieces of news, you will see the recommendating list in the first channel. The recommendating result consists of two parts. The first 
part is top recommendating according to the most interested type in your portrait. In this example, it seems that **gcr-recsys-user** is very interested in
the entertainment, the first 2-3 lines of recommendating list are entertainment news:

![Top-Type-News](/images/top-type-news.png)

The second part is generated from the similar contents of what you clicked. If you click 'recommend' again, you will get another recommendating list:

![Recommend-type-1](/images/recommend-type-1.png)
![Recommend-type-2](/images/recommend-type-2.png)






