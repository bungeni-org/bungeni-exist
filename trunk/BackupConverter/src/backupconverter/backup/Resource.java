package backupconverter.backup;


import java.io.InputStream;

/**
 * @author Adam Retter <adam.retter@googlemail.com>
 * @version 1.0
 */
public class Resource extends Item
{
    private InputStream inputStream = null;

    public Resource(String path, InputStream inputStream)
    {
        super(path);
        this.inputStream = inputStream;
    }

    public InputStream getInputStream()
    {
        return this.inputStream;
    }
}
