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
담당 : 김수종(본인)
---
* 년도별 재구매율(Retention Rate)
  * 다음 년도에도 연속해서 구매 이력을 가지는 구매자의 비율
* 국가별 년도별 재구매율 조회
  * 특정 국가에 거주하는 구매자 중 다음 년도에도 연속해서 구매 이력을 가지는 구매자의 비율
