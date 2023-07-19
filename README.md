# 웹스크래핑을 이용한 미국 주식 배당금 현황 보기

### 결론
![image](https://github.com/kimsujong90/Portfolio/assets/126228404/b727e6bd-7c4f-4047-ac2b-913511ce4fae)

### 목적
1주일에 한번씩 수기로 입력했었던 미국 주식 배당 정보를 스크래핑으로 좀 더 손쉽게 확인해볼 수 있게 코딩함

### 과정
Selenium과 Beautifulsoup을 이용한 웹스크래핑

1. https://www.stockanalysis.com에서 일별 주가 목록 스크래핑 불가하여 https://www.investing.com/에서 해당 항목 가져옴
   
   > https://www.stockanalysis.com - 차트로 되어 있는 주가 정보 (스크래핑 불가)
   ![image](https://github.com/kimsujong90/Portfolio/assets/126228404/addff95e-ed42-4c86-955c-7ffb49e8c10b)  
       
   > https://www.investing.com - 목록으로 되어 있는 주가 정보
   ![image](https://github.com/kimsujong90/Portfolio/assets/126228404/21b98fa0-141d-4efb-a777-95ab2680ad8f)

2. 사이트별 스크래핑 방식
   * https://www.stockanalysis.com : Request and BeautifulSoup, 되도록 성능이 빠른 BeautifulSoup을 사용
   * https://www.investing.com : selenium, BeautifulSoup으로 접근하려했으나 막혀 selenium을 통해 접근

3. 단계별로 추출된 데이터 중 일자별 배당금, 일자별 주가, 배당 빈도(배당을 지급하는 빈도로 월/분기/반기/연도로 나눠짐)를
   활용하여  
   특정 계산식에 따라 3년 중 최고 배당률이 어떻게 되는지 구함

### Note
* https://www.investing.com 사이트는 주기적으로 html 태그명이 변경되어 스크래핑이 원활하게 안될 때가 있었습니다.  
  태그 위치로 지정하려고 했으나 각 항목별로 위치가 상이하여 추출이 안되는 정보가 있습니다.  
  사이트 정보가 변경되어도 스크래핑에 문제가 없을 수 있는 방법을 고민하고 있습니다.  
  
* https://www.stockanalysis.com 사이트 상 주식 관련 정보가 N/A로 변경된 것들이 있었습니다.  
  N/A로 변경 시 pass 되는 구문을 추가할 예정입니다.  

* 티커만 추가한다면 배당 정보가 출력될 수 있는 상태입니다.  
  다만 사용자 입장에서 좀 더 편의성 있게 입력 할 수 있는 방안을 연구중입니다.  
  
  
