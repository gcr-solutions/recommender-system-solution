---
title: Experience As An End User
weight: 40
---

## Explore the user experience
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

You will also notice that there are scores for the type of news you may like:

![User-Portrait](/images/user-portrait.png)

If you navigate the recommendating list, you will notice some results with disparity tag. This means the system will push some types of news that you never read to discover the possible interests:

![Disparity](/images/disparity.png)

Now, you know almost everything about this demo. Please feel free to have a try!

## How to generate recommendating list (optional)

If you have interests in understanding more about the knowledge behind this engine, you can check the following content. 

If it is the first time that you login, the recommendating list will come from cold start logic. And each time you click the news, the user portrait will update.

If you click news at least 3 times, the recommendating list will come from the a sequence of logic, from recall to filter:

![Application Logic](/images/application-logic.png)






