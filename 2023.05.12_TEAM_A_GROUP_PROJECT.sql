-- --------------------------------------------------------------------------
-- 일별/월별/년도별 매출액 조회                                        발표자 : 정남용
-- --------------------------------------------------------------------------
-- 'payments' 테이블과 'orders', 'orderdetails' 테이블을 기반으로 매출액을 산출하는 경우에 차이가 발생하는 이유
-- 데이터의 차이: 'payments' 테이블은 결제 정보를 포함하고 있으며, 'orders'와 'orderdetails' 테이블은 주문 정보와 제품 상세 정보가 포함됨. 
--             따라서 두 테이블은 서로 다른 데이터를 가지고 있을 수 있음. 예를 들어, 'payments' 테이블에는 결제가 이루어지지 않은 주문이나 부분적으로 결제된 주문이 있을 수 있음.

-- 집계 방식: 'payments' 테이블은 결제 단위로 데이터가 기록되어 있으며, 각 결제에 대한 금액이 포함됨. 
--           반면에 'orders'와 'orderdetails' 테이블은 주문 단위로 데이터가 기록되어 있으며, 주문당 제품 가격과 수량을 곱한 값을 합산하여 매출액을 계산. 
--           따라서, 결제 테이블과 주문 테이블 간의 집계 방식의 차이로 인해 매출액이 다를 수 있음.

-- 조인 기준: 'payments' 테이블은 'customerNumber'를 기준으로 고객 정보와 결제 정보를 연결함. 
--          반면에 'orders'와 'orderdetails' 테이블은 'orderNumber'를 기준으로 주문 정보와 제품 상세 정보를 연결함.
--          따라서, 때로는 고객별로 여러 주문이 있을 수 있고, 주문별로 여러 제품 상세 정보가 있을 수 있으므로, 조인 기준에 따라 매출액이 다를 수 있음.

-- 연간 매출 
SELECT year(paymentDate) 'yearly_data', sum(amount) 'Total'
FROM payments
GROUP BY year(paymentDate)
ORDER BY year(paymentDate) ASC;

SELECT YEAR(orderDate) AS `Year`, SUM(quantityOrdered * priceEach) AS `Total Sales`
FROM orders AS o
JOIN orderdetails AS od ON o.orderNumber = od.orderNumber
GROUP BY YEAR(orderDate)
ORDER BY `Year`;

-- 월별 매출
SELECT year(paymentDate), MONTH(paymentDate), sum(amount)
FROM payments
GROUP BY year(paymentDate), MONTH(paymentDate)
ORDER BY year(paymentDate), MONTH(paymentDate) ASC;

SELECT YEAR(o.orderDate) AS `Year`, MONTH(o.orderDate) AS `Month`, 
       SUM(od.quantityOrdered * od.priceEach) AS `Sales`
FROM orderdetails AS od
JOIN orders AS o ON od.orderNumber = o.orderNumber
GROUP BY YEAR(o.orderDate), MONTH(o.orderDate)
ORDER BY `Year`, `Month`;

-- 일별 매출
SELECT year(paymentDate), MONTH(paymentDate), day(paymentDate), sum(amount)
FROM payments
GROUP BY year(paymentDate), MONTH(paymentDate), day(paymentDate) with ROLLUP
ORDER BY year(paymentDate), MONTH(paymentDate), day(paymentDate) ASC;

SELECT o.orderDate AS `Date`, SUM(od.quantityOrdered * od.priceEach) AS `Total Sales`
FROM orders AS o
JOIN orderdetails AS od ON o.orderNumber = od.orderNumber
GROUP BY o.orderDate
ORDER BY `Date`;

-- --------------------------------------------------------------------------
-- 일별/월별/년도별 구매자 수, 구매 건수 조회                             발표자 : 정남용
-- --------------------------------------------------------------------------

-- 년도별 구매자 수 및 구매건수
SELECT YEAR(o.orderDate) AS `Year`, COUNT(DISTINCT o.customerNumber) AS `Unique Customers`, 
       COUNT(*) AS `Total Orders`
FROM orders AS o
JOIN customers AS c ON o.customerNumber = c.customerNumber
GROUP BY YEAR(o.orderDate)
ORDER BY 'YEAR';

SELECT YEAR(p.paymentDate) AS `Year`, COUNT(DISTINCT p.customerNumber) AS `Unique Customers`, 
       COUNT(*) AS `Total Purchases`
FROM payments AS p
JOIN customers AS c ON p.customerNumber = c.customerNumber
GROUP BY YEAR(p.paymentDate)
ORDER BY `Year`;

-- 월별 구매자 수 및 구매건수
SELECT YEAR(o.orderDate) AS `Year`, MONTH(o.orderDate) AS `Month`, 
       COUNT(DISTINCT o.customerNumber) AS `Unique Customers`, COUNT(*) AS `Total Orders`
FROM orders AS o
JOIN customers AS c ON o.customerNumber = c.customerNumber
GROUP BY YEAR(o.orderDate), MONTH(o.orderDate)
ORDER BY `Year`, `Month`;

SELECT YEAR(p.paymentDate) AS `Year`, MONTH(p.paymentDate) AS `Month`, 
       COUNT(DISTINCT p.customerNumber) AS `Unique Customers`, COUNT(*) AS `Total Purchases`
FROM payments AS p
JOIN customers AS c ON p.customerNumber = c.customerNumber
GROUP BY YEAR(p.paymentDate), MONTH(p.paymentDate)
ORDER BY `Year`, `Month`;

-- 일별 구매자 수 및 구매건수
SELECT orderDate AS `Date`, COUNT(DISTINCT o.customerNumber) AS `Unique Customers`, 
       COUNT(*) AS `Total Orders`
FROM orders AS o
JOIN customers AS c ON o.customerNumber = c.customerNumber
GROUP BY orderDate
ORDER BY `Date`;

SELECT p.paymentDate AS `Date`, COUNT(DISTINCT p.customerNumber) AS `Unique Customers`, 
       COUNT(*) AS `Total Purchases`
FROM payments AS p
JOIN customers AS c ON p.customerNumber = c.customerNumber
GROUP BY p.paymentDate
ORDER BY `Date`;

-- --------------------------------------------------------------------------
-- 년도별 인당 매출액 (AMV)                                          발표자 : 정남용
-- --------------------------------------------------------------------------

-- 년도별 인당 매출액
SELECT YEAR(o.orderDate) AS `Year`, SUM(od.quantityOrdered * od.priceEach) / 
       COUNT(DISTINCT o.customerNumber) AS `Sales per Customer`
FROM orders AS o
JOIN customers AS c ON o.customerNumber = c.customerNumber
JOIN orderdetails AS od ON o.orderNumber = od.orderNumber
GROUP BY YEAR(o.orderDate)
ORDER BY `Year`;

SELECT YEAR(p.paymentDate) AS `Year`, SUM(p.amount) / 
	   COUNT(DISTINCT p.customerNumber) AS `Sales per Customer`
FROM payments AS p
JOIN customers AS c ON p.customerNumber = c.customerNumber
GROUP BY YEAR(p.paymentDate)
ORDER BY `Year`;

-- --------------------------------------------------------------------------
-- 년도별 건당 매출액 (ATV)                                          발표자 : 정남용
-- --------------------------------------------------------------------------
-- [거래 1건당 평균 매출액]

-- 년도별 건당 매출액
SELECT YEAR(o.orderDate) AS `Year`, SUM(od.quantityOrdered * od.priceEach) / 
       COUNT(*) AS `Sales per Order`
FROM orders AS o
JOIN orderdetails AS od ON o.orderNumber = od.orderNumber
GROUP BY YEAR(o.orderDate)
ORDER BY `Year`;

SELECT YEAR(paymentDate) AS `Year`, SUM(amount) / COUNT(*) AS `Sales per Order`
FROM payments
GROUP BY YEAR(paymentDate)
ORDER BY `Year`;

-- --------------------------------------------------------------------------
-- 국가별, 도시별 매출액 조회                                         발표자 : 나지원
-- --------------------------------------------------------------------------

-- 국가별 매출액
SELECT c.country, SUM(od.quantityOrdered * od.priceEach) AS total_sales_country -- 그룹화된 결과를 sum 함수를 사용해 매출액 계산
	FROM orders o JOIN customers c ON o.customerNumber = c.customerNumber
				  JOIN orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY c.country; -- country로 그룹화

-- 도시별 매출액
SELECT c.city, SUM(od.quantityOrdered * od.priceEach) AS total_sales_city
	FROM orders o JOIN customers c ON o.customerNumber = c.customerNumber
				  JOIN orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY c.city; -- city로 그룹화

-- --------------------------------------------------------------------------
-- 북미(USA, Canada) vs 비북미 매출액 비교 조회                        발표자 : 나지원
-- --------------------------------------------------------------------------

-- 북미/비북미를 구분하는 칼럼이 없으므로 customers 테이블의 country 칼럼을 이용해 구분
SELECT
	CASE
		WHEN c.country IN ('USA', 'Canada', 'Mexico') THEN 'North America'
        ELSE 'Non-North America'
	END AS region, -- case문을 사용하여 북미와 비북미를 지정하고 이를 rigion 칼럼에 저장
    SUM(od.quantityOrdered * od.priceEach) AS total_sales
FROM orders o JOIN customers c ON o.customerNumber = c.customerNumber
			  JOIN orderdetails od ON o.orderNumber = od.orderNumber -- 테이블을 조인하여 각각의 매출액 계산
GROUP BY region; -- 구한 매출액을 region 칼럼을 기준으로 그룹화

-- --------------------------------------------------------------------------
-- 국가별 매출액 TOP 5 및 순위 조회                                   발표자 : 나지원
-- --------------------------------------------------------------------------

-- 1번 방법
-- 서브쿼리와 RANK() 함수를 사용해서 국가별 매출액 순위를 구한 후 바깥에서 WHERE 조건을 사용해서 상위 5개 국가 선택
SELECT *
FROM (
    SELECT c.country, SUM(od.quantityOrdered * od.priceEach) AS total_sales, -- 매출액 계산
           RANK() OVER (ORDER BY SUM(od.quantityOrdered * od.priceEach) DESC) AS sales_rank -- 매출액을 기준으로 내림차순 랭킹 지정
    FROM orders o JOIN customers c ON o.customerNumber = c.customerNumber -- orders 테이블과 customers 테이블 조인
                  JOIN orderdetails od ON o.orderNumber = od.orderNumber -- orders 테이블과 orderdetails 테이블 조인
    GROUP BY c.country -- customers 테이블의 country 칼럼으로 그룹화
) ranked_sales
WHERE sales_rank <= 5; -- 앞서 만든 sales_rank 칼럼에서 sales_rank가 5이하인 데이터만 추출하는 조건 생성

-- 2번 방법
SELECT c.country, 
       SUM(od.quantityOrdered * od.priceEach) AS total_sales, -- 매출액 계산
       RANK() OVER (ORDER BY SUM(od.quantityOrdered * od.priceEach) DESC) AS sales_rank -- 매출액을 기준으로 내림차순 랭킹 지정
FROM orders o JOIN customers c ON o.customerNumber = c.customerNumber -- orders 테이블과 customers 테이블 조인
			  JOIN orderdetails od ON o.orderNumber = od.orderNumber -- orders 테이블과 orderdetails 테이블 조인
GROUP BY c.country  -- customers 테이블의 country 칼럼으로 그룹화
ORDER BY total_sales DESC -- 매출액을 기준으로 내림차순 정렬
LIMIT 5; -- LIMIT를 사용해 정렬 순서대로 상위 5개만 반환

-- --------------------------------------------------------------------------
-- 년도별 재구매율                                                   발표자 : 김수종
-- --------------------------------------------------------------------------
-- [다음년도에도 연속해서 구매 이력을 가지는 구매자의 비율]

-- 코딩 결론
-- 최종 결과값(5항)을 구성하기 위해서는 아래 여러 항목 중 2가지 항목(2-2항, 4-2항)만 필요하다.
-- 따라서 중간 사고과정이 필요없을 시 2-2항, 4-2항, 5항 총 3가지 항목만 봐도 무방하다.
-- 하지만 추후 사고과정을 학습하기 위해 남겨놓길 추천한다.

-- 0. 정보 파악 
--    > customers : 122, orders : 326
--    > orders.customerNumber : int, FK
--    > orders.orderDate : date
--    > 'Cancelled'건은 매출로 연결되지 않았으므로 구매에서 제외한다.

-- 1. 각 연도별로 중복되지 않은 구매자의 수를 '뷰'로 만들자 ('Cancelled' 건 제외)
-- 수정 가능하게 'or replace' 추가함
-- 추후 편의성을 위해 AS 필수, 문구 변경 시 수정사항 기재 요망
-- 해당연도 '동일인'의 총 주문량을 '1'로 변경하여 다른 주문과 중복된 수량을 제한하여 순수 인원수만 구할 수 있게 하기 위함
-- status상의 취소건들을 제외함

CREATE OR REPLACE VIEW total_buying AS  
  SELECT o1.customerNumber customerNo,  
         year(o1.orderDate) yr, 
         (count(o1.customerNumber)/count(o2.customerNumber)) cnt    
  FROM orders o1
       INNER JOIN orders o2 ON (year(o1.orderDate) = year(o2.orderDate) AND 
							   o1.customerNumber = o2.customerNumber)
  WHERE o1.status NOT IN ('Cancelled')   
  GROUP BY YEAR(o1.orderDate), 
           o1.customerNumber; 

-- 2-1. 1항의 total_buying 뷰를 이용하여 연도별 구매한 사람들 총합 구해보기
-- sum(cnt)는 'cnt'로 인해 'customerNumber'당 1로 반환된 값들을 전부 더해줌
SELECT yr year, sum(cnt) No_of_total_buying  
FROM total_buying
GROUP BY yr;

-- 연도별 구매한 사람들의 총합 (총 204명)
-- year       : No_of_total_buying
-- 2003       : 73
-- 2004       : 87
-- 2005       : 44

-- 2-2. 2-1항을 최종적으로 뷰로 만들자 - 한번에 결과를 얻을 수 있도록!
-- 수정 가능하게 'or replace' 추가함
-- 변환된 서브쿼리를 합산하여 연도별로 총합을 확인 할 수 있게 만든다.
-- 연도별 중복되지 않은 각각의 구매자 수가 1로 변환된 서브쿼리
-- 해당연도 '동일인'의 총 주문량을 '1'로 변경하여 다른 주문과 중복된 수량을 제한하여 순수 인원수만 구할 수 있게 하기 위함
-- status상의 취소건들을 제외함 

CREATE OR REPLACE VIEW Final_total_buying AS  
  SELECT yr, sum(cnt) No_of_total_buying  
  FROM (SELECT o1.customerNumber customerNo,  
               year(o1.orderDate) yr,
			   (count(o1.customerNumber)/count(o2.customerNumber)) cnt    	    
		FROM orders o1
             INNER JOIN orders o2 ON (year(o1.orderDate) = year(o2.orderDate) AND 
									 o1.customerNumber = o2.customerNumber)
	    WHERE o1.status NOT IN ('Cancelled')  
        GROUP BY YEAR(o1.orderDate),
                 o1.customerNumber) tb1 
  GROUP BY yr;

-- 3. 1항의 뷰를 참고하여 반복 구매 동일인의 중복 값 제거 뷰 만들기 ('Cancelled' 건 제외)
-- 수정 가능하게 'or replace' 추가함
-- AS 문구 변경 시 수정사항 기재 요망
-- 다른 주문과 중복된 수량을 제한하여 순수 인원수만 구하기 위함
-- status상의 취소건들을 제외함 
CREATE OR REPLACE VIEW remove_duplicate AS 
  SELECT o1.customerNumber customerNo,
         YEAR(o1.orderDate) yr,  
         (count(o1.customerNumber)/count(o2.customerNumber)) cnt 
  FROM orders o1 
       INNER JOIN orders o2 ON (year(o1.orderDate) = year(o2.orderDate)-1) 
  WHERE o1.status NOT IN ('Cancelled')  
  GROUP BY YEAR(o1.orderDate),  
           o1.customerNumber; 

-- 4-1. 3항의 remove_duplicate 뷰를 이용하여 연도별 연속으로 구매한 사람들 총합 구하기
-- sum(cnt)는 절로 인해 'customerNumber'당 1로 반환된 값들을 전부 더해줌
SELECT yr 1st_buying, sum(cnt) No_of_keep_buying  
FROM remove_duplicate
GROUP BY yr;

-- 연도별 연속으로 구매한 사람들의 총합 (총 98명)
-- 1st_buying : No_of_total_buying
-- 2003       : 64
-- 2004       : 34
-- (2005년은 연속데이터값(2006년)이 없기 때문에 반환이 안되는게 맞다.)

-- 4-2. 3항과 4-1항을 최종적으로 합친 뷰를 만들자
-- 수정 가능하게 'or replace' 추가함
-- 변환된 서브쿼리를 합산하여 연도별로 연속 구매자의 총합을 확인 할 수 있게 만든다.
-- 연도별 중복되지 않은 각각의 연속 구매자 수가 1로 변환된 서브쿼리
-- AS 문구 변경 시 수정사항 기재 요망
-- 다른 주문과 중복된 수량을 제한하여 순수 인원수만 구하기 위함
-- status상의 취소건들을 제외함
CREATE OR REPLACE VIEW Final_remove_duplicate AS  
  SELECT yr, sum(cnt) No_of_keep_buying 
  FROM (SELECT o1.customerNumber customerNo, 
               year(o1.orderDate) yr,  
               (count(o1.customerNumber)/count(o2.customerNumber)) cnt  
        FROM orders o1
             INNER JOIN orders o2 ON (year(o1.orderDate) = year(o2.orderDate)-1 AND 
						             o1.customerNumber = o2.customerNumber)
	    WHERE o1.status NOT IN ('Cancelled')   
        GROUP BY YEAR(o1.orderDate),  
                 o1.customerNumber) tb2  
  GROUP BY yr;

-- 5. 2항의 총 구매인원과 4항의 연도별 연속 구매인원 데이터를 가지고 재구매율을 구해보자
-- 재구매율 = (연속 구매인원 / 총 구매인원) * 100
SELECT ftb.yr 1st_buying, 
       round(((frd.No_of_keep_buying / ftb.No_of_total_buying) * 100),2) 'retention_rate(%)' 
FROM Final_total_buying ftb
     INNER JOIN Final_remove_duplicate frd ON ftb.yr = frd.yr;

-- 연도별 재구매율
-- 1st_buying : retention_rate(%)
-- 2003       : 87.67
-- 2004       : 39.08

-- --------------------------------------------------------------------------
-- 국가별 년도별 재구매율 조회                                         발표자 : 김수종
-- --------------------------------------------------------------------------
-- [특정 국가에 거주하는 구매자 중 다음 년도에도 연속해서 구매 이력을 가지는 구매자의 비율

-- 먼저 작성한 연도별 재구매율을 적극 참고한다.
-- 최종 값 산출 시 Inner Join에서 "AND ct.cc = ckb.cc" 이 명령어를 안 적어서 데카르트 곱처럼 되어 한참을 고생했다.
-- group by로 묶은 후 결과값이 중복되어 나오면 inner join 확인 필수

-- 0. 정보 파악 
--    > customers : 122, orders : 326, country : 21
--    > customers.customerNumber : int, PK
--    > customers.customerName/contactLastName/contactFirstName : varchar(50)
--    > orders.customerNumber : int, FK
--    > orders.orderDate : date
--    > 'Cancelled'건은 매출로 연결되지 않았으므로 구매에서 제외한다.

-- 1. 각 국가별 연도별로 중복되지 않은 구매자의 수를 '뷰'로 만들자 ('Cancelled' 건 제외 및 먼저 작성했던 연도별 자료에 따라 한번에 작성한다.)
-- 변환된 서브쿼리를 합산하여 국가별, 연도별로 총합을 확인 할 수 있게 만듬
-- 국가별, 연도별 중복되지 않은 각각의 구매자 수가 1로 변환된 서브쿼리
-- status상의 취소건들을 제외함 

CREATE OR REPLACE VIEW country_total AS
  SELECT cc, yr, sum(c_cnt) No_of_country_total 
  FROM (SELECT c.country cc,  
               count(DISTINCT c.country) c_cnt, 
               year(o1.orderDate) yr,
               o1.customerNumber
        FROM orders o1
	         INNER JOIN orders o2
                        ON (year(o1.orderDate) = year(o2.orderDate) AND 
						   o1.customerNumber = o2.customerNumber)
             INNER JOIN customers c
                        ON o2.customerNumber = c.customerNumber
        WHERE o1.status NOT IN ('Cancelled')  
        GROUP BY c.country,
                 YEAR(o1.orderDate), 
		         (o1.customerNumber)) ct1
  GROUP BY cc, yr;

-- 국가별 연도별 구매한 사람들의 총합 (총 204명 / 아래는 방대한 자료로 인해 요약한 표임)
-- year       : country_total
-- 2003       : 73
-- 2004       : 87
-- 2005       : 44

-- 2. 각 국가별 연도별로 중복되지 않은 연속된 구매자의 수를 '뷰'로 만들자 ('Cancelled' 건 제외)
-- 변환된 서브쿼리를 합산하여 국가별, 연도별로 총합을 확인 할 수 있게 만듬
-- 국가별, 연도별 중복되지 않은 각각의 구매자 수가 1로 변환된 서브쿼리
-- status상의 취소건들을 제외함 

CREATE OR REPLACE VIEW country_keep_buying AS
  SELECT cc, yr, sum(c_cnt) country_keep_buying 
  FROM (SELECT c.country cc,  
               count(DISTINCT c.country) c_cnt,
               year(o1.orderDate) yr,
               o1.customerNumber
        FROM orders o1
	         INNER JOIN orders o2
             ON (year(o1.orderDate) = year(o2.orderDate)-1 AND 
                o1.customerNumber = o2.customerNumber)
             INNER JOIN customers c
             ON o2.customerNumber = c.customerNumber
        WHERE o1.status NOT IN ('Cancelled')  
        GROUP BY c.country,
                 YEAR(o1.orderDate), 
		         (o1.customerNumber)) ct2
  GROUP BY cc, yr;

-- 국가별 연도별 연속으로 구매한 사람들의 총합 (총 98명)
-- 1st_buying : No_of_total_buying
-- 2003       : 64
-- 2004       : 34
-- (2005년은 연속데이터값(2006년)이 없기 때문에 반환이 안되는게 맞다.)

-- 3. 1항의 총 구매인원과 2항의 연속 구매인원 데이터를 가지고 재구매율을 구해보자
-- 재구매율 = (연속 구매인원 / 총 구매인원) * 100

SELECT ckb.cc country, 
	   ckb.yr 1st_buying,
       round(((ckb.country_keep_buying/ct.No_of_country_total) * 100), 2) 'retention_rate(%)'  
FROM country_total ct
     INNER JOIN country_keep_buying ckb ON (ct.yr = ckb.yr AND ct.cc = ckb.cc);

-- 국가별 연도별 재구매율
-- country : 1st_buying : retention_rate(%)
-- Australia	2003	60.00
-- Australia	2004	66.67
-- Austria	    2003	50.00
-- Austria	    2004	100.00
-- Belgium	    2003	100.00
-- Belgium	    2004	100.00
-- Canada	    2003	100.00
-- Canada	    2004	33.33
-- Denmark	    2003	100.00
-- Denmark	    2004	50.00
-- Finland	    2003	100.00
-- Finland	    2004	100.00
-- France	    2003	87.50
-- France	    2004	54.55
-- Germany	    2003	100.00
-- Italy	    2003	100.00
-- Italy	    2004	25.00
-- Japan	    2004	50.00
-- New Zealand	2003	100.00
-- New Zealand	2004	100.00
-- Norway	    2003	100.00
-- Philippines	2003	100.00
-- Singapore	2003	100.00
-- Singapore	2004	100.00
-- Spain	    2003	100.00
-- Spain	    2004	20.00
-- Sweden	    2003	100.00
-- Sweden	    2004	50.00
-- UK	        2003	100.00
-- USA	        2003	84.62
-- USA	        2004	29.03

-- --------------------------------------------------------------------------
-- 미국의 베스트셀러 TOP 5 제품, 매출액, 순위 정보 조회                       발표자 : 김다혜
-- --------------------------------------------------------------------------

SELECT p.productName, sum(od.quantityOrdered) TotalQuantity, SUM(od.priceEach * od.quantityOrdered) TotalPrice,
	   rank() over (order by sum(od.quantityOrdered) DESC) rank_USA
FROM orderdetails od INNER JOIN products p ON od.productCode = p.productCode
					 INNER JOIN orders o ON od.orderNumber = o.orderNumber
					 INNER JOIN customers c ON o.customerNumber = c.customerNumber
WHERE c.country = 'USA'
GROUP BY p.productName
ORDER BY 2 DESC
LIMIT 5;

-- PROCESS
-- 베스트셀러 : 가장 많이 팔린 양을 기준

-- 1. 필요한 table 확인
-- 베스트셀러 top 5 : orderNumber & quantityOrdered From orderdetails
-- 매출액 : sum(quantityOrdered * priceEach) TotalPrice From orderdetails
SELECT * -- 2996
FROM orderdetails;

-- 제품명 : ProductName FROM products
SELECT p.productName -- 110
FROM products p;


-- 국가 정보 : country = 'USA'인 data FROM customers
SELECT * -- 36
FROM customers c
WHERE c.country = 'USA';


SELECT * -- 326
FROM orders;

-- 2. 필요한 table 연결하기
-- 먼저, orderdetails 테이블과 products, orders, customers 테이블들을 조인
-- od.productCode(PK, FK)와 p.productCode(PK)를 기준으로 products와 orderdetails 테이블을 JOIN
-- od.orderNumber(PK, FK)와 o.orderNumber(PK), o.customerNumber(FK)와 c.customerNumber(PK)를 기준으로 나머지 테이블들을 JOIN
-- orderdetails 테이블의 quantityOrdered의 누락방지를 위해, LEFT OUTER JOIN을 이용해 table 연결

SELECT * -- 2996개의 row를 return 하므로 누락된 값 없음
FROM orderdetails od LEFT OUTER JOIN products p ON od.productCode = p.productCode
					 LEFT OUTER JOIN orders o ON od.orderNumber = o.orderNumber
					 LEFT OUTER JOIN customers c ON o.customerNumber = c.customerNumber;

-- 그런데, INNER JOIN도 개수 같음
SELECT *
FROM orderdetails od INNER JOIN products p ON od.productCode = p.productCode
					 INNER JOIN orders o ON od.orderNumber = o.orderNumber
					 INNER JOIN customers c ON o.customerNumber = c.customerNumber;

-- 3. 미국 데이터만 조회하기

SELECT *
FROM orderdetails od INNER JOIN products p ON od.productCode = p.productCode
					 INNER JOIN orders o ON od.orderNumber = o.orderNumber
					 INNER JOIN customers c ON o.customerNumber = c.customerNumber
WHERE c.country = 'USA';

-- 4. 미국의 베스트셀러 TOP 5 제품, 매출액, 순위 정보 조회를 위한 column만 뽑아내기
-- 미국에서 판매된 제품명, 제품 별 판매량, 제품 별 매출액을 뽑아냄
-- productName(제품명)을 기준으로 판매량 합계와, 매출액 합계를 구함
SELECT p.productName, sum(od.quantityOrdered) TotalQuantity, SUM(od.priceEach * od.quantityOrdered) TotalPrice
FROM orderdetails od INNER JOIN products p ON od.productCode = p.productCode
					 INNER JOIN orders o ON od.orderNumber = o.orderNumber
					 INNER JOIN customers c ON o.customerNumber = c.customerNumber
WHERE c.country = 'USA'
GROUP BY p.productName;

-- 5. 베스트셀러 TOP 5만을 조회하기 위해 rank function을 사용해 순위를 매김
-- TotalQuantity를 기준으로 순위를 매김
-- LIMIT 5를 이용해 5개만 조회

SELECT p.productName, sum(od.quantityOrdered) TotalQuantity, SUM(od.priceEach * od.quantityOrdered) TotalPrice,
	   rank() over (order by sum(od.quantityOrdered) DESC) rank_USA
FROM orderdetails od INNER JOIN products p ON od.productCode = p.productCode
					 INNER JOIN orders o ON od.orderNumber = o.orderNumber
					 INNER JOIN customers c ON o.customerNumber = c.customerNumber
WHERE c.country = 'USA'
GROUP BY p.productName
ORDER BY 2 DESC
LIMIT 5;

-- --------------------------------------------------------------------------
-- 가입자 이탈율(Churn Rate) 조회                                      발표자 : 김다혜
-- --------------------------------------------------------------------------
-- [특정시점(2005년 6월 1일)을 기준으로 마지막 구매일이 일정기간(3개월=90일) 이상 지난 고객의 비율

-- 가입자 이탈율 = ( 2005년 6월 1일을 기준으로 3개월(= 90일) 이상 구매하지 않은 고객 수 = 마지막 orderdate가 2005년 3월 1일 이전인 사람) 
				-- / (2005년 6월 1일 이전에 구매한 고객 수 = 전체 고객 수) * 100

-- 최종 code
CREATE OR REPLACE VIEW churn_rate_vw AS
SELECT COUNT(DISTINCT CASE WHEN lo.last_order_date < '2005-06-01' - INTERVAL 90 DAY THEN lo.customerNumber END) NotPurchase,
	   COUNT(lo.customerNumber) TotalPurchase,
       (COUNT(DISTINCT CASE WHEN lo.last_order_date < '2005-06-01' - INTERVAL 90 DAY THEN lo.customerNumber END) / COUNT(lo.customerNumber)) * 100 churn_rate
FROM (SELECT o.customerNumber, MAX(o.orderDate) last_order_date
      FROM orders o
      WHERE o.orderDate < '2005-06-01'
      GROUP BY o.customerNumber) lo;

SELECT *
FROM churn_rate_vw;

-- PROCESSING
-- 1. 가입자 이탈율을 계산하기 위해 필요한 data 확인하기
-- orderDate, customerNumber FROM orders
SELECT *
FROM orders;

SELECT customerNumber, orderDate
FROM orders
ORDER BY customerNumber ASC;

-- 2. customerNumber 별 중복 값이 있는 것을 확인
-- 제일 최근 주문 날짜 1개만 필요하므로 MAX 함수를 이용하여 '2005-06-01'이전의 최근 주문 날짜를 선택
-- '2005-06-01' 이전의 날짜로 필터링 & customerNumber를 기준으로 그룹화
-- customerNumber도 중복 없이 한 개만 반환
SELECT o.customerNumber, MAX(o.orderDate) last_order_date
FROM orders o
WHERE o.orderDate < '2005-06-01'
GROUP BY o.customerNumber;

-- 3. '2005-06-01'을 기준으로 90일 이상 구매하지 않은 고객의 수 필요
-- 제일 최근 주문 날짜가 필요하므로 위에 만들었던 query를 sub_query로 사용
-- - INTERFAL 90 DAY를 이용해 기준날짜보다 90일 적은 기준 생성
-- sub_query의 결과를 이용하여 조건식 생성 -> 맨 처음 확인한 결과 customerNumber에 중복 값이 존재했으로, DISTINCT를 이용해 중복 값을 제거 한 후, COUNT
-- ==> 2005년 6월 1일을 기준으로 3개월( = 90일) 이상 구매하지 않은 고객 수
-- 처음 정의했던 가입자 이탈율에 맞춰서 main_query 작성

SELECT (COUNT(DISTINCT CASE WHEN lo.last_order_date < '2005-06-01' - INTERVAL 90 DAY THEN lo.customerNumber END) / COUNT(lo.customerNumber)) * 100 churn_rate
FROM (SELECT o.customerNumber, MAX(o.orderDate) last_order_date
      FROM orders o
      WHERE o.orderDate < '2005-06-01'
      GROUP BY o.customerNumber) lo;


-- 4. 전체 변수와 같이 확인하고 싶음
SELECT COUNT(DISTINCT CASE WHEN lo.last_order_date < '2005-06-01' - INTERVAL 90 DAY THEN lo.customerNumber END) NotPurchase,
	   COUNT(lo.customerNumber) TotalPurchase,
       (COUNT(DISTINCT CASE WHEN lo.last_order_date < '2005-06-01' - INTERVAL 90 DAY THEN lo.customerNumber END) / COUNT(lo.customerNumber)) * 100 churn_rate
FROM (SELECT o.customerNumber, MAX(o.orderDate) last_order_date
      FROM orders o
      WHERE o.orderDate < '2005-06-01'
      GROUP BY o.customerNumber) lo;

-- 5. churn_rate view 만들기
CREATE OR REPLACE VIEW churn_rate_vw AS
SELECT COUNT(DISTINCT CASE WHEN lo.last_order_date < '2005-06-01' - INTERVAL 90 DAY THEN lo.customerNumber END) NotPurchase,
	   COUNT(lo.customerNumber) TotalPurchase,
       (COUNT(DISTINCT CASE WHEN lo.last_order_date < '2005-06-01' - INTERVAL 90 DAY THEN lo.customerNumber END) / COUNT(lo.customerNumber)) * 100 churn_rate
FROM (SELECT o.customerNumber, MAX(o.orderDate) last_order_date
      FROM orders o
      WHERE o.orderDate < '2005-06-01'
      GROUP BY o.customerNumber) lo;

-- 6. 가입자 이탈율 정보 조회하기
SELECT *
FROM churn_rate_vw;


-- --------------------------------------------------------------------------
-- 이상으로 A조 발표를 마무리하겠습니다. 수고하셨습니다.
-- --------------------------------------------------------------------------