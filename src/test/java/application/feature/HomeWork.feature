@debug
Feature: Validate favorite and comment function

  Background: Preconditions
	* url apiUrl

  Scenario: Favorite articles
        # Step 1: Add new article (optimize here - Create a AddArticle.feature)
	* def newArticle = call read('classpath:helpers/AddArticle.feature')
        # Step 2: Get the favorites count and slug ID for the the article, save it to variables
	* def initialCount = newArticle.favoritesCount
	* def articleId = newArticle.slug
	* def title = newArticle.title
        # Step 3: Make POST request to increase favorites count for the article
	Given path 'articles/' + articleId + '/favorite'
	When method Post
	Then status 200
        # Step 4: Verify response schema
	* def isTimeValidator = read('classpath:helpers/TimeValidator.js')
	And match response.article ==
      """
      {
        "slug": "#string",
        "title": "#string",
        "description": "#string",
        "body": "#string",
        "tagList": [],
        "createdAt": "#? isTimeValidator(_)",
        "updatedAt": "#? isTimeValidator(_)",
        "favorited": '#boolean',
        "favoritesCount": 1,
        "author": {
            "username": "#string",
            "bio": '##boolean',
            "image": "#string",
            "following": '#boolean'
        }
    }
      """
        # Step 5: Verify that favorites article incremented by 1
	* match response.article.favoritesCount == initialCount + 1

        # Step 6: Get all favorite articles
    * def username = newArticle.username
    Given params {favorited: '#(username)'}
    Given path 'articles'
    When method Get
    Then status 200
        # Step 7: Verify response
    And match each response.articles ==
    """
	  {
		  "slug": "#string",
		  "title": "#string",
		  "description": "#string",
		  "body": "#string",
		  "tagList": [],
		  "createdAt": "#? isTimeValidator(_)",
		  "updatedAt": "#? isTimeValidator(_)",
		  "favorited": '#boolean',
		  "favoritesCount": 1,
		  "author": {
			  "username": "#string",
			  "bio": '##boolean',
			  "image": "#string",
			  "following": '#boolean'
		  }
	  }
    """
	And match response.articlesCount == '#number'
        # Step 8: Verify that slug ID from Step 2 exist in one of the favorite articles
  	And match response.articles[*].slug contains articleId
        # Step 9: Delete the article (optimize here with afterScenario - create a Hook.feature)
	* call read('classpath:helpers/Hook.feature') {id: '#(articleId)'}
	And match response == {}

  Scenario: Comment articles
        # Step 1: Add new article (optimize here - Create a AddArticle.feature)
	* def addNewArticle = call read('classpath:helpers/AddArticle.feature')
        # Step 2: Get the slug ID for the article, save it to variable
	* def artID = addNewArticle.slug
        # Step 3: Make a GET call to 'comments' end-point to get all comments
	Given path 'articles/', artID, '/comments'
	When method Get
        # Step 4: Verify response schema
	Then status 200
	And match response.comments == []
        # Step 5: Get the count of the comments array length and save to variable
	* def responseWithComments = response.comments
	* def initArticlesCount = responseWithComments.length

        # Step 6: Make a POST request to publish a new comment
  	Given path 'articles/', artID, '/comments'
	* def dataGenerator = Java.type('helpers.DataGenerator')
	* def comment = dataGenerator.getComment()
	And request {"comment": {"body": "#(comment)"}}
  	When method Post
        # Step 7: Verify response schema that should contain posted comment text
  	Then status 200
  	And match response.comment.body == comment
	* def commentId = response.comment.id

        # Step 8: Get the list of all comments for this article one more time
	Given path 'articles/', artID, '/comments'
	When method Get
        # Step 9: Verify number of comments increased by 1 (similar like we did with favorite counts)
  	Then status 200
	* def newResponseWithComments = response.comments
	* def newArticlesCount = newResponseWithComments.length
  	And match newArticlesCount == initArticlesCount + 1
        # Step 10: Make a DELETE request to delete comment
	Given path 'articles/', artID, '/comments/', commentId
  	When method Delete
  	Then status 200

        # Step 11: Get all comments again and verify number of comments decreased by 1
	Given path 'articles/', artID, '/comments'
	When method Get
	Then status 200
  	* def deletedResponseWithComments = response.comments
	* def deletedArticlesCount = deletedResponseWithComments.length
  	And match deletedArticlesCount == newArticlesCount -1
        # Step 12: Delete the article (optimize here with afterScenario - create a Hook.feature)
	* call read('classpath:helpers/Hook.feature') {id: '#(artID)'}
	And match response == {}