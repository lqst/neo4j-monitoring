//cypher-shell -a neo4j://neo4j-cluster-lb-neo4j:7687?tags=gds -d demo -u neo4j -p test1234
//cypher-shell -a bolt://localhost:7687 -d demo -u neo4j -p test1234
//cypher-shell -a bolt://server4:7687 -d demo -u neo4j -p test1234

call gds.license.state();

create (:Person{name:"Håkan"})-[:LIKES]->(:Person{name:"Cathrine"});


match (sourceNode:Person)-[:LIKES]->(targetNode:Person)
return gds.graph.project(
  "test",
  sourceNode,
  targetNode
);


call gds.pageRank.write(
  'test',
  {
    writeProperty: 'pagerank'
  }
);

call gds.graph.drop("test");