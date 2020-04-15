package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.ui.launchconfig.config;

import java.util.Optional;

import org.eclipse.core.databinding.conversion.Converter;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.Path;

public class StringToIFileConverter extends Converter<String, IFile> {

    public StringToIFileConverter() {
        super(String.class, IFile.class);
    }

    @Override
    public IFile convert(String fromObject) {
        return Optional.ofNullable(fromObject)
            .filter(s -> s.length() > 0)
            .map(Path::new)
            .map(path -> ResourcesPlugin.getWorkspace()
                .getRoot()
                .getFile(path))
            .orElse(null);
    }

}
