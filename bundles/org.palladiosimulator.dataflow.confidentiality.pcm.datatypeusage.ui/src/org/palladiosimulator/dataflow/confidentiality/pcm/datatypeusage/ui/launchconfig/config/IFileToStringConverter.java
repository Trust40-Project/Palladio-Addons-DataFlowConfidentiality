package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.ui.launchconfig.config;

import java.util.Optional;

import org.eclipse.core.databinding.conversion.Converter;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.IPath;

public class IFileToStringConverter extends Converter<IFile, String> {

    public IFileToStringConverter() {
        super(IFile.class, String.class);
    }

    @Override
    public String convert(IFile fromObject) {
        return Optional.ofNullable(fromObject)
            .map(IFile::getFullPath)
            .map(IPath::toPortableString)
            .orElse(null);
    }

}
