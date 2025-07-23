select
      concat(T.acct,'#') as acct,
      JrnlKy,
      DocNo,
      T.EXDESC,
      T.MLDESC,
      DATE(PostDate) as PostDate,
      Dimension1,
      T.Itemkey,
            (case 
          when T.brand='' 
               or T.brand is null and left(T.Itemkey,1)='8' 
               then 'CORPORATE' else 
               coalesce(T.brand,'Brand_Not_Tagged') end ) BRANDNAME,
      PRODUCTNAME,
      Segment,
      Amount,
      Item_qty,
      PerItemCost,
      RecUserID
      from
      (
      SELECT
        'BM' as SourceF,
        glp.Acct as acct,
        max(glp.Dimension1) as Dimension1,
        max(JrnlKy) as JrnlKy,
        max(DocNo) as DocNo,
        prx.ex_desc as EXDESC,
        prx.ml_desc as MLDESC,
        prx.Segment,
        cast((FORMAT_DATETIME('%Y-%m-%d',PostDate)) as DATE) as PostDate,
        ifnull(glp.Itemkey,'N/A') Itemkey,
        glp.brand,
        ifnull(sum(glp.TrnAmt),0) as Amount,
        ABS(ifnull(sum(glp.trnqty),0)) as Item_qty,
        ABS (CASE WHEN SUM(trnqty) = 0 THEN 0 ELSE SUM(TrnAmt) / SUM(trnqty) END) AS PerItemCost,
        max(RecUserID) as RecUserID
      FROM

      (
        SELECT
          ml.Acct AS acct,
          ce.ExpenseGroupDescription AS ex_desc,
          ml.Description AS ml_desc,
          (CASE
              WHEN ml.CUSTOM2='6130' THEN 'Formulation'
              WHEN ml.CUSTOM2='6131' THEN 'AHD'
              WHEN ml.CUSTOM2='6132' THEN 'IBD'
          END
            ) AS Segment
        FROM
          bm.bm_cust_expensegroup AS ce,
          bm.bm_mdfltledgers AS ml
        WHERE
          ce.ExpenseGroupID=ml.CUSTOM3
          AND ml.CUSTOM2 IN ('6130','6131','6132')
          AND ml.CUSTOM3 NOT IN ('618', '630', '631', '632')
          AND ml.custom3<>'901' ) AS prx

      left join

        (
select
t1.Acct,
JrnlKy,
DocNo,
DATE(t1.PostDate) as PostDate,
t1.Dimension1,
t1.Itemkey,
t1.TrnAmt,
t1.trnqty,
(case when t1.Dimension1<>'' or t1.Dimension1 is not null then t1.brand end) as brand,
RecUserID
from
          (
          select
          Acct,
          JrnlKy,
          DocNo,
          PostDate,
          Dimension1,
          t.Itemkey,
          TrnAmt,
          trnqty,
          (case
          when t.ITEMKEY='' then f.DimensionDesc
          when t.ITEMKEY is null then f.DimensionDesc
          when i.BRANDNAME='' then f.DimensionDesc
          when i.BRANDNAME is null then f.DimensionDesc
          -- when left(t.ITEMKEY,1)='8' then 'CORPORATE'
          else i.BRANDNAME end) as brand,
          RecUserID

          from (
               select
                    Acct,
                    cast((FORMAT_DATETIME('%Y-%m-%d', gl.AplDate)) as date) AS PostDate,
                    JrnlKy,
                    gl.DocNo,
                    LTRIM(D.Dimension1, '0') as Dimension1,
                    (case
                         when JrnlKy='JE' then CUSTOM1
                         when JrnlKy='CV' then CUSTOM6
                         when JrnlKy='HC' then CUSTOM6
                         when JrnlKy='AP' then ap.CUSTOM4
                         when JrnlKy='HV' then ap.CUSTOM4
                         else gl.Itemkey end ) as Itemkey,
                    RecUserID,
                    TrnAmt,
                    trnqty
                    from
                    `bm.bm_glpost` as gl
                    left join
                    (select Vouchno,Itemkey,CUSTOM4 from `bm.bm_aplin`) as ap

                    on gl.Vouchno=ap.Vouchno
                    left join
                    (SELECT
                         DocNo,
                         MAX(Dimension1) AS Dimension1
                    FROM `bm.bm_glpost`
                    WHERE DATE(AplDate) between '2025-06-01' and '2025-06-30'
                          --and DATE(AplDate) <= '2025-05-30'
                          --  AND DocNo = 'OI-899500'
                          AND Dimension1<>'NULL'
                    GROUP BY DocNo) as D

                    on gl.DocNo=D.DocNo
                    where
                    -- AplDate between '2024-09-01 00:00:00' and '2024-09-30 00:00:00'
                    DATE(AplDate) between '2025-06-01' and '2025-06-30'
                    and Acct<>'6665500190100000310'
          ) as t
left join `bm.ItemInfo` as i
on t.Itemkey=i.ITEMKEY
left join (SELECT  LTRIM(DimensionID, '0') AS DimensionID, UPPER(ltrim(rtrim(DimensionDesc))) as DimensionDesc FROM `bm.bm_FinDimensionSetup` where MultiDimKey='Dimension 1'   ) as f
on t.Dimension1=f.DimensionID

-------------------------------------------

UNION ALL

-------------------------------------------
select
          Acct,
          JrnlKy,
          DocNo,
          PostDate,
          Dimension1,
          Itemkey,
          TrnAmt,
          trnqty,
          (case when Dimension1<>'' or Dimension1 is not null then brand
          when left(Itemkey,1)='8' then 'CORPORATE' else coalesce(brand,'Brand_Not_Tagged') end) as brand,
          RecUserID from

(
          select
          Acct,
          JrnlKy,
          DocNo,
          PostDate,
          Dimension1,
          f.DimensionDesc,
          t.Itemkey,
          TrnAmt,
          trnqty,
          case when f.DimensionDesc is null then i.BRANDNAME  else f.DimensionDesc end as brand,
          RecUserID

          from (
               select
                    Acct,
                    cast((FORMAT_DATETIME('%Y-%m-%d', gl.AplDate)) as date) AS PostDate,
                    JrnlKy,
                    gl.DocNo,
                    LTRIM(D.Dimension1, '0') as Dimension1,
                    (case
                         when JrnlKy='JE' then CUSTOM1
                         when JrnlKy='CV' then CUSTOM6
                         when JrnlKy='HC' then CUSTOM6
                         when JrnlKy='AP' then ap.CUSTOM4
                         when JrnlKy='HV' then ap.CUSTOM4
                         else gl.Itemkey end ) as Itemkey,
                    RecUserID,
                    TrnAmt,
                    trnqty
                    from
                    `bm.bm_glpost` as gl
                    left join
                    (select Vouchno,Itemkey,CUSTOM4 from `bm.bm_aplin`) as ap

                    on gl.Vouchno=ap.Vouchno
                    left join
                    (SELECT
                         DocNo,
                         MAX(Dimension1) AS Dimension1
                    FROM `bm.bm_glpost`
                    WHERE DATE(AplDate) between '2025-06-01' and '2025-06-30'
                          --and DATE(AplDate) <= '2025-05-30'
                          --  AND DocNo = 'OI-899500'
                          AND Dimension1<>'NULL'
                    GROUP BY DocNo) as D

                    on gl.DocNo=D.DocNo
                    where
                    -- AplDate between '2024-09-01 00:00:00' and '2024-09-30 00:00:00'
                    DATE(AplDate) between '2025-06-01' and '2025-06-30'
                    and Acct='6665500190100000310'
          ) as t
left join `bm.ItemInfo` as i
on t.Itemkey=i.ITEMKEY
left join (SELECT  LTRIM(DimensionID, '0') AS DimensionID, UPPER(ltrim(rtrim(DimensionDesc))) as DimensionDesc FROM `bm.bm_FinDimensionSetup` where MultiDimKey='Dimension 1'   ) as f
on t.Dimension1=f.DimensionID
) as t2

---------------------------------------------------------------------------------

) as t1


        ) As glp
          on prx.acct=glp.Acct
          group by   glp.Acct,
                      prx.ex_desc,
                      prx.ml_desc,
                      prx.Segment,
                      glp.Itemkey,
                      glp.PostDate,
                      glp.brand
          having glp.PostDate is not null
      ) T
      left join
      (select ITEMKEY,PRODUCTNAME,UPPER(ltrim(rtrim(BRANDNAME))) as PBRANDNAME from `bm.ItemInfo`) i
      on T.Itemkey=i.ITEMKEY
