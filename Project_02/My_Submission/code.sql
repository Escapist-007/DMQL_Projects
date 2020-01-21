/*
    Name: Md Moniruzzaman Monir
    Ubit : mdmoniru
    Person #: 50291708
*/


                                            /*
                                                PROBLEM 01 :
                                                ============
                                            */


                ###### S1

/*
    Explanation :

    First I get the count of vendors for every category using GROUP BY command. The result is stored in the relation "A".
    Then I find the categories having the maximum number of vendors which is in the relation "Cname_Highest_Vendor".
    Finally I select the vendors which have its Cname in the "Cname_Highest_Vendor" relation.
*/


WITH A AS
    (SELECT Cname, COUNT(Cname) AS Vcount
     FROM Vendor
     GROUP BY Cname),

    Cname_Highest_Vendor AS
        (SELECT Cname
         FROM Vendor
         GROUP BY Cname
         HAVING COUNT(Cname) = (SELECT MAX(A.Vcount) FROM A))

SELECT Vname
FROM Vendor
WHERE Cname IN (SELECT Cname FROM Cname_Highest_Vendor)
ORDER BY Cname;





                ###### S2

/*
    Explanation :
    First I find the vendors whose revenue is greater than 2 million (2000000). Then I find the products sold by those vendors.
*/

SELECT DISTINCT Pname
FROM Sell
WHERE Vname IN (SELECT Vname
                FROM Vendor
                WHERE Revenue > 2000000);






                ###### S3

/*
     Explanation :

     First I am creating a relation 'V' using the self joining technique in "Vendor" table.
     In "V", for every vendor I store the name of the vendors which are in the same category and higher revenue.

     For example, if in category "c1" there are 3 vendors v1, v2, v3 with revenue 100, 200 and 300, then for v1 we will get
     (v1,v2) and (v1,v3) rows in "V" table because v2 and v3 both have higher revenue than v1. For v2 we will get (v2,v3)
     row and for v3 there will be no row as there is no other vendors in "c1" category which has higher revenue than v3.

     Then I create another relation 'M' by joining 'V' and Sell tables. Here, I use left join so if there is no product for a
     vendor in the sell table it will be included and there should be NULL in the average price. There is another query which
     is commented out that exclude the vendors with no product in the sell table.

     Finally, for every vendor I get the average price of products for vendors with higher revenue and in the same category
     using GROUP BY command in the 'M' table.

*/


WITH V AS
    (SELECT V1.Vname AS Vendor, V2.Vname as VHR
     FROM Vendor V1, Vendor V2
     WHERE V1.Vname  <> V2.Vname AND V1.Cname   = V2.Cname AND V1.Revenue < V2.Revenue),

     M AS
    (SELECT V.Vendor, V.VHR, S.Pname, S.price
     FROM V LEFT JOIN Sell S
     ON V.VHR = S.Vname)

SELECT
    M.Vendor AS Vname, AVG(M.Price) AS Avg_Price
FROM
    M
GROUP BY
    M.Vendor
ORDER BY 1;


# SELECT
#   M.Vendor AS Vname, AVG(M.Price) AS Avg_Price
# FROM
#   (SELECT
#      V.Vendor, V.VHR, S.Pname, S.price
#    FROM
#     ( SELECT V1.Vname AS Vendor, V2.Vname as VHR
#       FROM Vendor V1, Vendor V2
#       WHERE V1.Vname <> V2.Vname
#       AND V1.Cname = V2.Cname
#       AND V1.Revenue < V2.Revenue ) V, Sell S
#     WHERE V.VHR = S.Vname
#     ) M
# GROUP BY M.Vendor


# Relational Algebra

Among these 3 queries only "S2" has an equivalent relational algebra formulation. Because for S1 and S3 we have to use "Aggregate
Functions" and aggregate functions are not expressible in relational algebra. In S1, we need the categories having maximum number
of vendors and for getting the maximum vendor counts we use "MAX" aggregate function. Similarly in S3, we need average price of
products and for that we use "AVG" aggregate function.


Relation Algebra formulation of S2:
-----------------------------------

#  πPname ( Sell  ⋈  (πVname (𝞼Revenue > 2000000 (Vendor))) )



                                            /*
                                                    PROBLEM 02 :
                                                    ============
                                            */

                ### SQL Schema

# Stores the vertices of the graph

CREATE TABLE Nodes (
    v INT NOT NULL,
    PRIMARY KEY (v)
);

# Stores the directed labelled edges of the graph

CREATE TABLE Edges (
    s INT NOT NULL,
    d INT NOT NULL,
    color VARCHAR(100),
    FOREIGN KEY (s) REFERENCES Nodes(v),
    FOREIGN KEY (d) REFERENCES Nodes(v)
);


# INSERT INTO Nodes(v)
# VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11);

# INSERT INTO Edges (s, d, color)
# VALUES  (1, 2,  'yellow'),
#         (1, 4,  'blue'),
#         (2, 3,  'yellow'),
#         (2, 5,  'blue'),
#         (2, 10, 'green'),
#         (3, 4,  'green'),
#         (3, 1,  'yellow'),
#         (4, 10, 'green'),
#         (5, 6,  'green'),
#         (7, 8,  'green'),
#         (8, 9,  'green'),
#         (9, 7,  'green'),
#         (10, 11, 'yellow');



                ##### 2.1 (SQL3)

# FIND ALL PAIRS OF NODES CONNECTED BY PATH CONSISTING OF GREEN OR YELLOW EDGES

/*
    Explanation :

    I create a view 'YG_Edges' which stores only the yellow and green edges. Then I use SQL3 (WITH RECURSIVE command) to generate
    all pairs of nodes connected by path which includes only green or yellow edges.
*/

CREATE VIEW YG_Edges(s,d) AS
    (SELECT E.s, E.d
     FROM Edges E
     WHERE E.color ='yellow' OR E.color='green'
    );


WITH RECURSIVE Pair(s,d) AS
    (# Base Query
      SELECT s,d
      FROM YG_Edges

      UNION

     # Recursive Query
      SELECT P.s, E.d
      FROM Pair P, YG_Edges E
      WHERE P.d = E.s
    )
SELECT s AS V1, d AS V2
FROM Pair
ORDER BY 1,2;




                ##### 2.2 (SQL2)

# FOR EVERY NODE, CALCULATE THE NUMBER OF OUTGOING EDGES

/*
    Explanation :

    Created a view "EC" which contains the number of outgoing edges for every source vertices in the "Edges" table. Then I left
    join the "Nodes" table with this view, and if any vertex has no outgoing edges then put 0 as number of outgoing edges
    using the COALESCE function.
*/

WITH EC(v, c) AS
    (SELECT E.s,count(*)
     FROM Edges E
     GROUP BY E.s)

SELECT N.v AS vertex, COALESCE(EC.c, 0) AS " Number of outgoing edges"
FROM Nodes N LEFT JOIN EC
ON N.v = EC.v;





                ##### 2.3 (SQL3)

# Find all pairs of nodes not connected by any path

/*
    Explanation :

    I create a view table "All_PAIR" using cross join. It contains all possible pairs. Then I use SQL3 (WITH RECURSIVE command) to
    generate all pairs of nodes connected by path which includes all color edges. Then finally the pairs that are in the
    "ALL_PAIR" view but not in the "Pair" table those are the required pair of nodes not connected by any path.

*/


CREATE VIEW All_PAIR(V1,V2) AS
    ( SELECT N1.v, N2.v
      FROM
        Nodes N1 CROSS JOIN Nodes N2
      ORDER BY 1, 2
    )

WITH RECURSIVE Pair(s,d) AS
    (# Base Query
      SELECT s,d
      FROM Edges

      UNION

    # Recursive Query
      SELECT P.s, E.d
      FROM Pair P, Edges E
      WHERE P.d = E.s
    )

SELECT V1, V2
FROM All_PAIR
WHERE (V1,V2) NOT IN (SELECT s, d FROM Pair);





                ##### 2.4 (Bonus) (SQL2)

# Find all the triangles of the same color

/*
    Explanation :

I use SQL2 to solve this bonus problem. First I create a table "L2" by self joining the "Edges" table. L2 includes the paths
having exactly 2 edges. Then I again join "L2" with "Edges" table to create the table "L3" which includes all the paths having
exactly 3 edges. If a path of 3 edges create a triangle then the first and last vertices will be same. Using this logic I create
another table "T" which includes all triangles. Finally from "T" I choose the triangles which have the some color in all 3 edges.
As there are 3 possible orderings of a triangle so I mention a specific order like (v1 < v2 < v3) to pick a triangle exactly
once.

*/


WITH L2 AS
        (SELECT
            E1.s AS V1,
            E1.d AS V2,
            E1.color as C1,
            E2.s AS V3,
            E2.d AS V4,
            E2.color AS C2
        FROM Edges E1, Edges E2
        WHERE E1.d = E2.s),

    L3 AS
        (SELECT
            E1.V1,
            E1.V2,
            E1.C1,
            E1.V3,
            E1.V4,
            E1.C2,
            E2.s AS V5,
            E2.d AS V6,
            E2.color AS C3
        FROM L2 E1, Edges E2
        WHERE E1.V4 = E2.s),

    T AS
        (SELECT *
         FROM L3
         WHERE V1=V6)

SELECT V1 AS V1,V3 AS V2,V5 AS V3, C1 AS "Triangle_Color"
FROM T
WHERE (C1 = C2 AND C1 = C3)
AND (V1 < V3 AND V3 < V5)
ORDER BY 1;





                                               /*
                                                   PROBLEM 03 :
                                                   ============
                                               */
/*
    Explanation :

    I create a view "Valid_ManSSN" which contains the 'ManSSN' that are in the 'SSN' list. So, if there is a ManSSN which doesn't
    refer to any SSN then it will not be included in the view table. Later I use a case statement and print 'yes' if the count of
    ManSSN in the view table and count of ManSSN in the Manager table are equal. Otherwise I print 'no' which indicates there are
    some ManSSN which violates the foreign key constraint "ManSSN references Manager(SSN)".

*/

CREATE VIEW Valid_ManSSN AS
    (SELECT ManSSN
     FROM Manager
     WHERE ManSSN IN (SELECT SSN FROM Manager)
    );

SELECT
CASE
    WHEN (SELECT COUNT(ManSSN) FROM Valid_ManSSN) = COUNT(M.ManSSN) THEN "yes"
    ELSE "no"
END AS "ManSSN references Manager(SSN)?"
FROM Manager M;
