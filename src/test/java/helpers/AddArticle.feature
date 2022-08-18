Feature: Create new article

  Background: Preconditions
	* url apiUrl
	* def dataGenerator = Java.type('helpers.DataGenerator')
	* def title = dataGenerator.getArticleName()

  Scenario: Create new article
	Given path 'articles'
	And request {"article": {"tagList": [],"title":'#(title)',"description": "des","body": "body"}}
	When method Post
	Then status 200
	* def favoritesCount = response.article.favoritesCount
	* def slug = response.article.slug
	* def title = response.article.title
	* def username = response.article.author.username
