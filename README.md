# SQL group project describe
------
# 목적
- MySQL의 기본 제공 데이터를 전처리하여 구매 지표를 추출 

# 사용 데이터
- 기본 제공 "classicmodels" 사용

- Features Description
  * Customers : store's customer's data
  * Products : stores a list of scale model cars
  * ProductLines : stores a list of product line categories
  * Orders : stores sales orders placed by customers
  * OrderDetails : stores sales order line items for each sales order
  * Payments : stores payments made by customers based on their accounts
  * Employees : stores all employee information as well as the organization structure reports to whom
  * Offices : stores sales office data

 
# Goal : 구매 지표 추출하기
---
담당 : 정남용
---
* 일별/월별/년도별 매출액 조회
* 일별/월별/년도별 구매자 수, 구매 건수 조회
* 년도별 인당 매출액 (AMV: Average Member value)
* 년도별 건당 매출액 (ATV: Average Transaction value)
  * 거래 1건당 평균 매출액

---
담당 : 나지원
---
* 국가별, 도시별 매출액 조회
* 북미(USA, Canada) vs 비북미 매출액 비교 조회
* 국가별 매출액 TOP 5 및 순위 조회

---
담당 : 김수종(본인)
---
* 년도별 재구매율(Retention Rate)
  * 다음 년도에도 연속해서 구매 이력을 가지는 구매자의 비율
* 국가별 년도별 재구매율 조회
  * 특정 국가에 거주하는 구매자 중 다음 년도에도 연속해서 구매 이력을 가지는 구매자의 비율

---
담당 : 김다혜
---
* 미국의 베스트셀러 TOP 5 제품, 매출액, 순위 정보 조회
* 가입자 이탈율(Churn Rate) 조회
  * 특정시점(2005년 6월 1일)을 기준으로 마지막 구매일이 일정기간(3개월=90일) 이상



