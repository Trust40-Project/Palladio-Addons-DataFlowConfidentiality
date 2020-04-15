package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.ui.launchconfig.config;

import java.util.Collection;
import java.util.Collections;
import java.util.HashSet;

import org.eclipse.core.resources.IFile;

public class Configuration {

    private final Collection<IFile> usageModels = new HashSet<>();
    private IFile outputFile;

    public IFile getOutputFile() {
        return outputFile;
    }

    public void setOutputFile(IFile outputFile) {
        this.outputFile = outputFile;
    }

    public Collection<IFile> getUsageModels() {
        return Collections.unmodifiableCollection(usageModels);
    }

    public void setUsageModels(Collection<IFile> files) {
        usageModels.clear();
        usageModels.addAll(files);
    }

}
