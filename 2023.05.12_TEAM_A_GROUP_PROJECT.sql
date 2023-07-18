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
