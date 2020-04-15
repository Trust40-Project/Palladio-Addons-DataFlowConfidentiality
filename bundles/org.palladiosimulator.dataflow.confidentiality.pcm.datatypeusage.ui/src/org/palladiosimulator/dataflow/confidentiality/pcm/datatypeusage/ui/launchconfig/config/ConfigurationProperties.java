package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.ui.launchconfig.config;

public enum ConfigurationProperties {

    USAGE_MODELS("usagemodels"),
    OUTPUT("output");
    
    private static final String PREFIX = "org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.";
    private final String key;
    
    private ConfigurationProperties(String key) {
        this.key = PREFIX + key;
    }
    
    public String getKey() {
        return key;
    }
    
}
