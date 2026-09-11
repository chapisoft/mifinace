package com.bmf.mobile.infra.persistence;

import com.bmf.mobile.domain.entity.LoanApplication;
import com.bmf.mobile.domain.enums.LoanApplicationStatus;
import com.bmf.mobile.domain.repository.LoanApplicationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.stereotype.Repository;

import java.sql.Timestamp;
import java.util.List;
import java.util.Optional;

/**
 * Triển khai JDBC truy vấn bảng SYS_LOAN_APPLICATION trên SQL Server.
 */
@Repository
@RequiredArgsConstructor
public class JdbcLoanApplicationRepository implements LoanApplicationRepository {

    private final JdbcClient jdbcClient;

    @Override
    public void save(LoanApplication app) {
        String sql = """
            INSERT INTO dbo.SYS_LOAN_APPLICATION (
                Application_ID, Customer_Code, Customer_Name, NRC_Number, Group_Code,
                Loan_Product_Code, Requested_Amount, Term_Months, Purpose,
                GPS_Latitude, GPS_Longitude, NRC_Front_Image_URL, NRC_Back_Image_URL,
                Survey_Image_URL, Signature_Image_URL, Status, Credit_Score,
                Created_By, Created_Time
            ) VALUES (
                :applicationId, :customerCode, :customerName, :nrcNumber, :groupCode,
                :loanProductCode, :requestedAmount, :termMonths, :purpose,
                :gpsLatitude, :gpsLongitude, :nrcFrontImageUrl, :nrcBackImageUrl,
                :surveyImageUrl, :signatureImageUrl, :status, :creditScore,
                :createdBy, :createdTime
            )
            """;

        jdbcClient.sql(sql)
                .param("applicationId", app.getApplicationId())
                .param("customerCode", app.getCustomerCode())
                .param("customerName", app.getCustomerName())
                .param("nrcNumber", app.getNrcNumber())
                .param("groupCode", app.getGroupCode())
                .param("loanProductCode", app.getLoanProductCode())
                .param("requestedAmount", app.getRequestedAmount())
                .param("termMonths", app.getTermMonths())
                .param("purpose", app.getPurpose())
                .param("gpsLatitude", app.getGpsLatitude())
                .param("gpsLongitude", app.getGpsLongitude())
                .param("nrcFrontImageUrl", app.getNrcFrontImageUrl())
                .param("nrcBackImageUrl", app.getNrcBackImageUrl())
                .param("surveyImageUrl", app.getSurveyImageUrl())
                .param("signatureImageUrl", app.getSignatureImageUrl())
                .param("status", app.getStatus().name())
                .param("creditScore", app.getCreditScore())
                .param("createdBy", app.getCreatedBy())
                .param("createdTime", Timestamp.valueOf(app.getCreatedTime()))
                .update();
    }

    @Override
    public Optional<LoanApplication> findById(String applicationId) {
        String sql = """
            SELECT Application_ID, Customer_Code, Customer_Name, NRC_Number, Group_Code,
                   Loan_Product_Code, Requested_Amount, Term_Months, Purpose,
                   GPS_Latitude, GPS_Longitude, NRC_Front_Image_URL, NRC_Back_Image_URL,
                   Survey_Image_URL, Signature_Image_URL, Status, Credit_Score,
                   Created_By, Created_Time, Updated_Time
            FROM dbo.SYS_LOAN_APPLICATION
            WHERE Application_ID = :applicationId
            """;

        return jdbcClient.sql(sql)
                .param("applicationId", applicationId)
                .query((rs, rowNum) -> mapRow(rs))
                .optional();
    }

    @Override
    public List<LoanApplication> findByCustomerCode(String customerCode) {
        String sql = """
            SELECT Application_ID, Customer_Code, Customer_Name, NRC_Number, Group_Code,
                   Loan_Product_Code, Requested_Amount, Term_Months, Purpose,
                   GPS_Latitude, GPS_Longitude, NRC_Front_Image_URL, NRC_Back_Image_URL,
                   Survey_Image_URL, Signature_Image_URL, Status, Credit_Score,
                   Created_By, Created_Time, Updated_Time
            FROM dbo.SYS_LOAN_APPLICATION
            WHERE Customer_Code = :customerCode
            ORDER BY Created_Time DESC
            """;

        return jdbcClient.sql(sql)
                .param("customerCode", customerCode)
                .query((rs, rowNum) -> mapRow(rs))
                .list();
    }

    @Override
    public List<LoanApplication> findByGroupCode(String groupCode) {
        String sql = """
            SELECT Application_ID, Customer_Code, Customer_Name, NRC_Number, Group_Code,
                   Loan_Product_Code, Requested_Amount, Term_Months, Purpose,
                   GPS_Latitude, GPS_Longitude, NRC_Front_Image_URL, NRC_Back_Image_URL,
                   Survey_Image_URL, Signature_Image_URL, Status, Credit_Score,
                   Created_By, Created_Time, Updated_Time
            FROM dbo.SYS_LOAN_APPLICATION
            WHERE Group_Code = :groupCode
            ORDER BY Created_Time DESC
            """;

        return jdbcClient.sql(sql)
                .param("groupCode", groupCode)
                .query((rs, rowNum) -> mapRow(rs))
                .list();
    }

    @Override
    public void updateStatus(String applicationId, LoanApplicationStatus status) {
        String sql = """
            UPDATE dbo.SYS_LOAN_APPLICATION
            SET Status = :status, Updated_Time = SYSUTCDATETIME()
            WHERE Application_ID = :applicationId
            """;

        jdbcClient.sql(sql)
                .param("status", status.name())
                .param("applicationId", applicationId)
                .update();
    }

    private LoanApplication mapRow(java.sql.ResultSet rs) throws java.sql.SQLException {
        Timestamp createdTs = rs.getTimestamp("Created_Time");
        Timestamp updatedTs = rs.getTimestamp("Updated_Time");

        return LoanApplication.builder()
                .applicationId(rs.getString("Application_ID"))
                .customerCode(rs.getString("Customer_Code"))
                .customerName(rs.getString("Customer_Name"))
                .nrcNumber(rs.getString("NRC_Number"))
                .groupCode(rs.getString("Group_Code"))
                .loanProductCode(rs.getString("Loan_Product_Code"))
                .requestedAmount(rs.getBigDecimal("Requested_Amount"))
                .termMonths(rs.getInt("Term_Months"))
                .purpose(rs.getString("Purpose"))
                .gpsLatitude(rs.getBigDecimal("GPS_Latitude"))
                .gpsLongitude(rs.getBigDecimal("GPS_Longitude"))
                .nrcFrontImageUrl(rs.getString("NRC_Front_Image_URL"))
                .nrcBackImageUrl(rs.getString("NRC_Back_Image_URL"))
                .surveyImageUrl(rs.getString("Survey_Image_URL"))
                .signatureImageUrl(rs.getString("Signature_Image_URL"))
                .status(LoanApplicationStatus.valueOf(rs.getString("Status")))
                .creditScore(rs.getObject("Credit_Score") != null ? rs.getInt("Credit_Score") : null)
                .createdBy(rs.getString("Created_By"))
                .createdTime(createdTs != null ? createdTs.toLocalDateTime() : null)
                .updatedTime(updatedTs != null ? updatedTs.toLocalDateTime() : null)
                .build();
    }
}
