package org.palladiosimulator.dataflow.confidentiality.pcm.model.profile;

public class ProfileConstants {

    public static StereotypeDescription dataChannelBehavior = new StereotypeDescription("DataChannelBehaviour",
            "behaviour");
    public static StereotypeDescription characterisable = new StereotypeDescription("Characterisable",
            "characteristics");

    public static class StereotypeDescription {
        private final String stereotype;
        private final String value;

        public StereotypeDescription(String stereotype, String valueName) {
            this.stereotype = stereotype;
            this.value = valueName;
        }

        public String getStereotype() {
            return stereotype;
        }

        public String getValue() {
            return value;
        }

    }

}
