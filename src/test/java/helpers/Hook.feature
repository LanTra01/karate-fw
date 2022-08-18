Feature: Delete article

  Background: afterScenario
	* url apiUrl

  Scenario: Delete article
	* def articleId = {id: '#(id)'}
	Given path 'articles/', articleId.id
	When method Delete
	Then status 200
