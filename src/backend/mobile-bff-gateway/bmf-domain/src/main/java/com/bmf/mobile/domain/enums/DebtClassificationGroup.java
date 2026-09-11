package com.bmf.mobile.domain.enums;

/**
 * Phân loại 5 nhóm nợ và trích lập dự phòng rủi ro theo quy định FRD Myanmar.
 */
public enum DebtClassificationGroup {
    GROUP_1_CURRENT("Nhóm 1 - Nợ đủ tiêu chuẩn (Dưới 30 ngày quá hạn)", 0, 30),
    GROUP_2_SPECIAL_MENTION("Nhóm 2 - Nợ cần chú ý (Từ 31 đến 60 ngày quá hạn)", 31, 60),
    GROUP_3_SUBSTANDARD("Nhóm 3 - Nợ dưới tiêu chuẩn (Từ 61 đến 90 ngày quá hạn)", 61, 90),
    GROUP_4_DOUBTFUL("Nhóm 4 - Nợ nghi ngờ (Từ 91 đến 180 ngày quá hạn)", 91, 180),
    GROUP_5_LOSS("Nhóm 5 - Nợ có khả năng mất vốn (Trên 180 ngày quá hạn)", 181, 9999);

    private final String description;
    private final int minOverdueDays;
    private final int maxOverdueDays;

    DebtClassificationGroup(String description, int minOverdueDays, int maxOverdueDays) {
        this.description = description;
        this.minOverdueDays = minOverdueDays;
        this.maxOverdueDays = maxOverdueDays;
    }

    public String getDescription() {
        return description;
    }

    public int getMinOverdueDays() {
        return minOverdueDays;
    }

    public int getMaxOverdueDays() {
        return maxOverdueDays;
    }

    public static DebtClassificationGroup fromOverdueDays(int overdueDays) {
        if (overdueDays <= 30) {
            return GROUP_1_CURRENT;
        } else if (overdueDays <= 60) {
            return GROUP_2_SPECIAL_MENTION;
        } else if (overdueDays <= 90) {
            return GROUP_3_SUBSTANDARD;
        } else if (overdueDays <= 180) {
            return GROUP_4_DOUBTFUL;
        } else {
            return GROUP_5_LOSS;
        }
    }
}
