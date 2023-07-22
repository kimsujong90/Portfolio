# [캐글] Amazon-employee-access-challenge
* 추신 : 아직 공부하는 과정입니다. 계속 업데이트 될 예정입니다.

### 목적
---
직원들의 보직 변경 시 누구에게 access 권한이 필요하고 필요없는지 분류하는 머신러닝 만들기
데이터셋 : https://www.kaggle.com/competitions/amazon-employee-access-challenge

### 과정
---
#### 분석
1. "RESOURCE, MGR_ID, ROLE_ROLLUP_1, ROLE_ROLLUP_2, ROLE_DEPTNAME, ROLE_TITLE, ROLE_FAMILY_DESC, ROLE_FAMILY, ROLE_CODE"
총 9개의 Feature가 존재하며 중복된 행과 결측치는 없음을 확임함
2. 다만 target열의 0값이 너무 적어 과소적합이 되지 않을까하는 우려가 있음, 다만 오버샘플링은 과적합을 유발할 수 있어 추후 결과 확인 후 적용할 필요가 있을 것 같음
3. 각 데이터의 숫자는 연속형이 아닌 명목형으로 직책이나 직급 등의 의미를 나타내는 고유의 값이 있음. 혹시라도 의미가 완전 똑같이 중복되는 열이 있으면 삭제하려하였으나 완전 중복된 열은 없었음
#### 모델 선정
1. 원핫인코딩과 라벨인코딩 중 예상과는 달리 원핫인코딩이 더 성능이 잘나와 원핫인코딩을 사용함
2. LGBoost, XGBoost, CATBoost, RandomForest 중 XGBoost나 CATBoost가 성능이 제일 좋을 것으로 예상했으나 RandomForest가 제일 잘 나와 해당 모델을 사용하기로 하였음
   
### 결과
---
gridcv로는 아래와 같이 나왔으나
1. 최적의 파라미터는 {'max_depth': 300, 'min_samples_leaf': 1, 'min_samples_split': 3, 'n_estimators': 500}
2. 최고 스코어는 : 0.8259

실제 테스트 결과 0.6514의 결과 값이 나왔다.

### Note
---
- 최적합 점수가 82%이나 실제 테스트셋은 62%인점 -> 과적합 의심
  * 해결방안
  1. 원핫인코딩 -> 라벨인코딩
     - 원핫인코딩은 피처수가 너무 많아지므로 과적합이 우려되긴했었다.
     - 라벨인코딩으로 변경하여 적용해보는 게 좋을 것 같다.
  2. 오버샘플링 적용
     - 데이터 EDA 시 1값이 압도적으로 많은 것을 볼 수 있었다.
     - 라벨인코딩으로도 잘 안되면 오버샘플링을 적용해보자.
