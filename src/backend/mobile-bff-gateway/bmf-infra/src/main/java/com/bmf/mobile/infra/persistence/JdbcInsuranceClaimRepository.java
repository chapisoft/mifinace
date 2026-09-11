package com.bmf.mobile.infra.persistence;

import com.bmf.mobile.domain.entity.InsuranceClaim;
import com.bmf.mobile.domain.enums.InsuranceClaimStatus;
import com.bmf.mobile.domain.enums.InsuranceRiskType;
import com.bmf.mobile.domain.repository.InsuranceClaimRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.stereotype.Repository;

import java.sql.Timestamp;
import java.util.List;
import java.util.Optional;

/**
 * Triển khai JDBC truy vấn bảng SYS_INSURANCE_CLAIM trên SQL Server.
 */
@Repository
@RequiredArgsConstructor
public class JdbcInsuranceClaimRepository implements InsuranceClaimRepository {

    private final JdbcClient jdbcClient;

    @Override
    public void save(InsuranceClaim claim) {
        String sql = """
            INSERT INTO dbo.SYS_INSURANCE_CLAIM (
                Claim_ID, Customer_Code, Contract_Code, Risk_Type,
                Claim_Amount, Medical_Doc_URLs, Village_Head_Doc_URL, Description,
                Status, Submitted_By, Submitted_Time
            ) VALUES (
                :claimId, :customerCode, :contractCode, :riskType,
                :claimAmount, :medicalDocUrls, :villageHeadDocUrl, :description,
                :status, :submittedBy, :submittedTime
            )
            """;

        jdbcClient.sql(sql)
                .param("claimId", claim.getClaimId())
                .param("customerCode", claim.getCustomerCode())
                .param("contractCode", claim.getContractCode())
                .param("riskType", claim.getRiskType().name())
                .param("claimAmount", claim.getClaimAmount())
                .param("medicalDocUrls", claim.getMedicalDocUrls())
                .param("villageHeadDocUrl", claim.getVillageHeadDocUrl())
                .param("description", claim.getDescription())
                .param("status", claim.getStatus().name())
                .param("submittedBy", claim.getSubmittedBy())
                .param("submittedTime", Timestamp.valueOf(claim.getSubmittedTime()))
                .update();
    }

    @Override
    public Optional<InsuranceClaim> findById(String claimId) {
        String sql = """
            SELECT Claim_ID, Customer_Code, Contract_Code, Risk_Type,
                   Claim_Amount, Medical_Doc_URLs, Village_Head_Doc_URL, Description,
                   Status, Submitted_By, Submitted_Time, Approved_Time, Approved_By
            FROM dbo.SYS_INSURANCE_CLAIM
            WHERE Claim_ID = :claimId
            """;

        return jdbcClient.sql(sql)
                .param("claimId", claimId)
                .query((rs, rowNum) -> InsuranceClaim.builder()
                        .claimId(rs.getString("Claim_ID"))
                        .customerCode(rs.getString("Customer_Code"))
                        .contractCode(rs.getString("Contract_Code"))
                        .riskType(InsuranceRiskType.valueOf(rs.getString("Risk_Type")))
                        .claimAmount(rs.getBigDecimal("Claim_Amount"))
                        .medicalDocUrls(rs.getString("Medical_Doc_URLs"))
                        .villageHeadDocUrl(rs.getString("Village_Head_Doc_URL"))
                        .description(rs.getString("Description"))
                        .status(InsuranceClaimStatus.valueOf(rs.getString("Status")))
                        .submittedBy(rs.getString("Submitted_By"))
                        .submittedTime(rs.getTimestamp("Submitted_Time").toLocalDateTime())
                        .approvedTime(rs.getTimestamp("Approved_Time") != null ? rs.getTimestamp("Approved_Time").toLocalDateTime() : null)
                        .approvedBy(rs.getString("Approved_By"))
                        .build())
                .optional();
    }

    @Override
    public List<InsuranceClaim> findByCustomerCode(String customerCode) {
        String sql = """
            SELECT Claim_ID, Customer_Code, Contract_Code, Risk_Type,
                   Claim_Amount, Medical_Doc_URLs, Village_Head_Doc_URL, Description,
                   Status, Submitted_By, Submitted_Time, Approved_Time, Approved_By
            FROM dbo.SYS_INSURANCE_CLAIM
            WHERE Customer_Code = :customerCode
            ORDER BY Submitted_Time DESC
            """;

        return jdbcClient.sql(sql)
                .param("customerCode", customerCode)
                .query((rs, rowNum) -> InsuranceClaim.builder()
                        .claimId(rs.getString("Claim_ID"))
                        .customerCode(rs.getString("Customer_Code"))
                        .contractCode(rs.getString("Contract_Code"))
                        .riskType(InsuranceRiskType.valueOf(rs.getString("Risk_Type")))
                        .claimAmount(rs.getBigDecimal("Claim_Amount"))
                        .medicalDocUrls(rs.getString("Medical_Doc_URLs"))
                        .villageHeadDocUrl(rs.getString("Village_Head_Doc_URL"))
                        .description(rs.getString("Description"))
                        .status(InsuranceClaimStatus.valueOf(rs.getString("Status")))
                        .submittedBy(rs.getString("Submitted_By"))
                        .submittedTime(rs.getTimestamp("Submitted_Time").toLocalDateTime())
                        .approvedTime(rs.getTimestamp("Approved_Time") != null ? rs.getTimestamp("Approved_Time").toLocalDateTime() : null)
                        .approvedBy(rs.getString("Approved_By"))
                        .build())
                .list();
    }

    @Override
    public void updateStatus(String claimId, InsuranceClaimStatus status, String approvedBy) {
        String sql = """
            UPDATE dbo.SYS_INSURANCE_CLAIM
            SET Status = :status, Approved_By = :approvedBy, Approved_Time = SYSUTCDATETIME()
            WHERE Claim_ID = :claimId
            """;

        jdbcClient.sql(sql)
                .param("status", status.name())
                .param("approvedBy", approvedBy)
                .param("claimId", claimId)
                .update();
    }
}
