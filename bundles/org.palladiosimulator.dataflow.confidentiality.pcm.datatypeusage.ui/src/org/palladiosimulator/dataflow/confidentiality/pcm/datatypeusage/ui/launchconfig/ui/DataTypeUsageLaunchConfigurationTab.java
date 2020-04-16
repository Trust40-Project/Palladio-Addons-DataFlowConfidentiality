package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.ui.launchconfig.ui;

import java.util.Collections;
import java.util.List;

import org.eclipse.core.resources.IFile;
import org.eclipse.debug.core.ILaunchConfiguration;
import org.eclipse.debug.core.ILaunchConfigurationWorkingCopy;
import org.eclipse.debug.ui.AbstractLaunchConfigurationTab;
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Composite;
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.ui.launchconfig.config.Configuration;
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.ui.launchconfig.config.ConfigurationSerializer;

public class DataTypeUsageLaunchConfigurationTab extends AbstractLaunchConfigurationTab  {

    private static final List<IFile> USAGE_MODELS_DEFAULT = Collections.emptyList();
    private static final IFile OUTPUT_DEFAULT = null;
    private final ConfigurationSerializer configSerializer = new ConfigurationSerializer(new Configuration());
    protected DataTypeUsageLaunchConfigurationTabComposite control;
    
    @Override
    public void createControl(Composite parent) {
        control = new DataTypeUsageLaunchConfigurationTabComposite(parent, SWT.FILL, this::handleDirtyEvent);
        setControl(control);
    }
    
    protected void handleDirtyEvent() {
        setDirty(true);
        updateLaunchConfigurationDialog();
    }

    @Override
    public void setDefaults(ILaunchConfigurationWorkingCopy configuration) {
        configSerializer.getConfiguration().setOutputFile(OUTPUT_DEFAULT);
        configSerializer.getConfiguration().setUsageModels(USAGE_MODELS_DEFAULT);
        configSerializer.write(configuration);
        refreshConfigFromUI();
    }

    @Override
    public void initializeFrom(ILaunchConfiguration configuration) {
        configSerializer.read(configuration);
        control.setOutput(configSerializer.getConfiguration().getOutputFile());
        control.setUsageModels(configSerializer.getConfiguration().getUsageModels());
    }

    @Override
    public void performApply(ILaunchConfigurationWorkingCopy configuration) {
        refreshConfigFromUI();
        configSerializer.write(configuration);
    }

    protected void refreshConfigFromUI() {
        if (control != null) {
            configSerializer.getConfiguration().setOutputFile(control.getOutput());
            configSerializer.getConfiguration().setUsageModels(control.getUsageModels());            
        }
    }

    @Override
    public String getName() {
        return "Data Type Usage Analysis";
    }

}
