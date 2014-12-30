# SpongeBob
=========

## Speed up development with T4 templates
The possibility to use T4 templates with powershell in Visual Studio is awesome. 
You can create projects or any kind of files automatically in your solution.

## What is SpongeBob?
SpongeBob is a set of T4-templates and Powershell files that will help you generate code based on your domain model.
SpongeBob is built to use Entity Framework Code First, so you can also reverse engineer databases and use SpongeBob with existing databases once you get the hang of it.

## What features is supported?
Right now SpongeBob will

 - Generate repository interfaces for your model
 - Generate service interfaces for your model
 - Generate a data layer using Entity Framework Code First
 - Generate a service layer
 - Generate viewmodels for each entity in the model
 - Generate all IoC for using the service layer and data layer with Unit Of Work
 - Provide validation when saving
 - Provide possibility for custom validation
 - Provide possibility to generate MVC controllers
 - Provide possibility to get IoC code for Ninject

## How?
Let's say that you are building a new web-app and have created an MVC project named "MyWeb" in Visual Studio 2013
Then just...

   Watch this video (link will be here)

## Roadmap
The plan is to also add

 - Templates for XSockets.NET so that you can generate realtime applications to be used from any client
 - Templates for Angular
 - Templates for KnockoutJS
 - Templates for vanilla-JS
