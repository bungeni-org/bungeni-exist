package org.bungeni.exist.tools.backupconverter.writer;


import org.bungeni.exist.tools.backupconverter.mapper.Mapper;
import org.bungeni.exist.tools.backupconverter.*;
import org.bungeni.exist.tools.backupconverter.backup.Collection;
import org.bungeni.exist.tools.backupconverter.backup.Item;
import org.bungeni.exist.tools.backupconverter.backup.Resource;
import org.bungeni.exist.tools.backupconverter.backup.reader.BackupReader;
import java.io.File;
import java.io.FilenameFilter;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * @author Adam Retter <adam.retter@googlemail.com>
 * @version 1.0
 */
public class ANFolderWriter implements ANWriter
{
    private final Mapper mapper;
    private final File dst;

    private final static Pattern countryPattern = Pattern.compile("[a-z]{3}");
    private final static Matcher countryMatcher = countryPattern.matcher("");
    private final static Pattern yearPattern = Pattern.compile("(19|20)[0-9]{2}");
    private final static Matcher yearMatcher = yearPattern.matcher("");
    private final static Pattern datePattern = Pattern.compile("(19|20)[0-9]{2}-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])");
    private final static Matcher dateMatcher = datePattern.matcher("");



    public ANFolderWriter(Mapper mapper, File dst)
    {
        this.mapper = mapper;
        this.dst = dst;
    }

    @Override
    public void writeCollection(Collection collection) throws IOException
    {
        if(mapper.shouldMap(collection))
        {
            String collectionPath = mapper.mapPath(collection);

            String lastSeg = collectionPath.substring(collectionPath.lastIndexOf(BackupReader.PATH_SEPARATOR)+1);
            yearMatcher.reset(lastSeg);
            if(!yearMatcher.matches())
            {
                new File(dst, collectionPath).mkdirs();
            }
        }
        //we dont need to do anything here in this instance,
        //all nessecary folders are created by writeResource
    }

    @Override
    public void writeResource(Resource resource) throws IOException
    {
        if(mapper.shouldMap(resource))
        {
            String anPath = mapper.mapPath(resource);

            File f = new File(dst, anPath);
            f.getParentFile().mkdirs();
            
            OutputStream os = new FileOutputStream(f);

            InputStream is = resource.getInputStream();

            int read = -1;
            byte buf[] = new byte[2048];

            while((read = is.read(buf)) > -1)
            {
                os.write(buf, 0, read);
            }

            os.close();
            is.close();
        }
    }

    @Override
    public void removeCollection(Item collection) throws IOException
    {
        if(mapper.shouldMap(collection))
        {
            String anPath = mapper.mapPath(new Collection(collection.getPath()));

            String lastSeg = anPath.substring(anPath.lastIndexOf(BackupReader.PATH_SEPARATOR)+1);
            if(lastSeg != null)
            {
                yearMatcher.reset(lastSeg);
                if(yearMatcher.matches())
                {
                    deleteYearFolders(new File(dst, anPath).getParentFile(), lastSeg);
                    return;
                }
            }

            File f = new File(dst, anPath);
            FileUtil.recursiveDelete(f);
        }
    }

    private void deleteYearFolders(File containerDir, final String year)
    {
        if(!containerDir.exists())
            return;

        File yearFolders[] = containerDir.listFiles(new FilenameFilter(){
            @Override
            public boolean accept(File dir, String name)
            {
                //is it a directory, does it start with the year, is it a valid date?
                File f = new File(dir, name);
                if(f.isDirectory() && name.startsWith(year))
                {
                    dateMatcher.reset(name);
                    return dateMatcher.matches();

                }
                return false;
            }

        });

        for(File yearFolder : yearFolders)
        {
            FileUtil.recursiveDelete(yearFolder);
        }
    }

    @Override
    public void removeResource(Item resource) throws IOException
    {
        if(mapper.shouldMap(resource))
        {
            String anPath = mapper.mapPath(new Resource(resource.getPath(), null));
            File f = new File(dst, anPath);

            f.delete();
        }
    }
}
