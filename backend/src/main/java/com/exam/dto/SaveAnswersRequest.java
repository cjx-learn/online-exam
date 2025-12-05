package com.exam.dto;

import lombok.Data;
import java.util.List;

@Data
public class SaveAnswersRequest {
    private List<AnswerItem> answers;

    @Data
    public static class AnswerItem {
        private Long questionId;
        private String answerValue;
    }
}
